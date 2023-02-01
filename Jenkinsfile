#!groovy
//noinspection GroovyUnusedAssignment
@Library('AuroraWorkflow2') _

properties [
    [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
]

pipeline {
    agent { label "deploy" }
    options { timestamps() }

    environment {
        CREATOR = "Job $JOB_NAME $BUILD_DISPLAY_NAME"
        HOST_NAME = "$NODE_NAME"
    }

    stages {
        stage('provision') {
            steps {
                script {
                    env.RESOURCE_GROUP = "dev-test-${new Date().format('yyMMddHHmm')}".toLowerCase()

                    currentBuild.description = "test-cluster in resource group ${RESOURCE_GROUP}"

                    withCredentials(
                        auroralib.secrets('DEV_SP')) {
                        docker.withRegistry(auroralib.HAUFE_REGISTRY, auroralib.HAUFE_REGISTRY_SECRET) {
                            sh './jenkins.sh'
                        }
                    }
                }
            }
        }
    }
}
