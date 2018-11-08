
def repository = 'github.com/igorsid/devops_training.git'
def nxhost = '192.168.10.10'
def lbhost = '192.168.10.11'
def tomcatn = 2
def version = ''

//@NonCPS
def parseVersion = { String txt ->
    def m = txt =~ /(\d+\.\d+\.\d+)/
    '' + m[0][1]
}

node('master') {

    stage('incversion') {
        sh 'cat /etc/hostname'
        git url: "https://${repository}", branch: 'task6', changelog: false, poll: false
        sh './gradlew incrementVersion'
        def fprops = readFile 'gradle.properties'
        version = parseVersion(fprops)
        if ( ! version ) {
            error 'Version defining error'
        }
        println "New version: '${version}'"
        sh './gradlew build'
        withCredentials([usernameColonPassword(credentialsId: 'fb1e45d9-8e07-439b-84b9-3d7af76a41e1', variable: 'nxcred')]) {
            sh "curl -X PUT -u $nxcred -T build/libs/task6-${version}.war http://${nxhost}:8081/nexus/content/repositories/test/${version}/test.war"
        }
    }

    for ( int i = 1; i <= tomcatn; ++i ) {
        def host = "tomcat${i}"

        stage(host) {
            node(host) {
                sh 'cat /etc/hostname'
                println "Get version: '${version}'"
                sh "curl -X GET -o test.war http://${nxhost}:8081/nexus/content/repositories/test/${version}/test.war"
                sh "curl 'http://${lbhost}/jkmanager?cmd=update&from=list&w=lb&sw=${host}&vwa=1'"
                withCredentials([usernameColonPassword(credentialsId: 'f3bf3b66-9e90-4080-bf7d-3afb11400a29', variable: 'tccred')]) {
                    sh "curl -T test.war 'http://${tccred}@localhost:8080/manager/text/deploy?path=/test&update=true'"
                }
                sleep 5
                //sh "curl http://localhost:8080/test/"
                def chk = sh returnStdout: true, script: 'curl http://localhost:8080/test/'
                if ( parseVersion(chk) != version ) {
                    error 'Application deploy failure'
                }
                sh "curl 'http://${lbhost}/jkmanager?cmd=update&from=list&w=lb&sw=${host}&vwa=0'"
            }
        }

    }

    stage('pushversion') {
        sh 'cat /etc/hostname'
        //sh "git checkout task6"
        sh 'git add gradle.properties'
        sh "git commit -m 'Increment version to ${version}'"
        withCredentials([usernameColonPassword(credentialsId: '8f2e341a-d5a2-43b7-a799-8f2efd9b58b4', variable: 'gitcred')]) {
            sh "git push https://${gitcred}@${repository}"
        }
        sh "git checkout master"
        sh "git pull"
        sh "git merge task6"
        withCredentials([usernameColonPassword(credentialsId: '8f2e341a-d5a2-43b7-a799-8f2efd9b58b4', variable: 'gitcred')]) {
            sh "git push https://${gitcred}@${repository}"
        }
        sh "git tag -a v${version} -m 'Version ${version}'"
        withCredentials([usernameColonPassword(credentialsId: '8f2e341a-d5a2-43b7-a799-8f2efd9b58b4', variable: 'gitcred')]) {
            sh "git push https://${gitcred}@${repository} v${version}"
        }
    }

}
