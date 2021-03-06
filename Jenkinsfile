#!groovy
import groovy.json.JsonSlurper
node {

    def BUILD_NUMBER=env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"
    def SFDC_USERNAME

    def HUB_ORG=env.HUB_ORG_DH
    def SFDC_HOST = env.SFDC_HOST_DH
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
    def CONNECTED_APP_CONSUMER_KEY=env.CONNECTED_APP_CONSUMER_KEY_DH

    def toolbelt = tool 'toolbelt'

    stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        stage('Create Scratch Org') {
 
            rc = bat returnStatus: true, script: "\"${toolbelt}/sfdx\" force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST}"
 
            if (rc != 0) { error 'hub org authorization failed' }
 
            // need to pull out assigned username
            String  rmsg = bat (returnStdout: true, script: "\"${toolbelt}/sfdx\" force:org:create --definitionfile config/project-scratch-def.json --json --setdefaultusername")
          
            println("stdout ################ " + rmsg + " ####################") 
            
            String[] values = rmsg.split('\r') 

            def jsonSlurper = new JsonSlurper()
            def robj = jsonSlurper.parseText(  values.last() );
            if (robj.status != 0 ) { error 'org creation failed: ' + robj.message }
            SFDC_USERNAME=robj.result.username 
            
            println("SFDC_USERNAME ################ " + robj.result.username  + " ####################") 

            robj = null 
        }

        stage('Push To Test Org') {
            rc = bat returnStatus: true, script: "\"${toolbelt}/sfdx\" force:source:push --targetusername ${SFDC_USERNAME}"
            if (rc != 0) {
                error 'push failed'
            }
            // assign permset
            rc = bat returnStatus: true, script: "\"${toolbelt}/sfdx\" force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname test_dx"
            if (rc != 0) {
                error 'permset:assign failed'
            }
        }

        stage('Run Apex Test') {
            String RUN_ARTIFACT_DIRS = "${RUN_ARTIFACT_DIR}".replace("/","\\") 
            bat "mkdir " + RUN_ARTIFACT_DIRS 

            timeout(time: 120, unit: 'SECONDS') {
                rc = bat returnStatus: true, script: "\"${toolbelt}/sfdx\" force:apex:test:run --testlevel RunLocalTests --outputdir " + RUN_ARTIFACT_DIRS  + "  --resultformat tap --targetusername ${SFDC_USERNAME}"
                if (rc != 0) {
                    error 'apex test run failed'
                }
            }
        }

        stage('collect results') {
            junit keepLongStdio: true, testResults: 'tests/**/*-junit.xml'
        }
    }
}