
def repository = 'github.com/igorsid/devops_training.git'
def branch = 'task7'
def nxhost = '192.168.10.10'
def lbhost = '192.168.10.10'
def workern = 2
def version = ''

//@NonCPS
def parseVersion = { String txt ->
    def m = txt =~ /(\d+\.\d+\.\d+)/
    '' + m[0][1]
}

node('master') {

    stage('incversion') {
        git url: "https://${repository}", branch: branch, changelog: false, poll: false
        sh './gradlew incrementVersion'
        def fprops = readFile 'gradle.properties'
        version = parseVersion(fprops)
        if ( ! version ) {
            error 'Version defining error'
        }
        println "New version: '${version}'"
        sh './gradlew build'
        withCredentials([usernameColonPassword(credentialsId: '68e9fec3-d951-4ebe-92c5-89ada557e71a', variable: 'nxcred')]) {
            sh "curl -X PUT -u $nxcred -T build/libs/${branch}-${version}.war http://${nxhost}:8081/nexus/content/repositories/${branch}/${version}/${branch}.war"
        }
    }

    stage('dockerimage') {
        sh "docker build . -t ${branch}:${version} --build-arg nxhost=${nxhost} --build-arg version=${version}"
        sh "docker tag ${branch}:${version} ${lbhost}:5000/${branch}:${version}"
        sh "docker push ${lbhost}:5000/${branch}:${version}"
    }

    stage('dockerswarm') {
        def chk = sh returnStatus: true, script: 'docker node ls'
        if ( chk != 0 ) {
            sh "docker swarm init --advertise-addr ${lbhost}"
            def token = sh returnStdout: true, script: 'docker swarm join-token -q worker'
            token = token.replaceAll( /\s*$/, '' )
            println "Worker token: ${token}"
            for ( int i = 1; i <= workern; ++i ) {
                node("worker${i}") {
                    sh "docker swarm join --token ${token} ${lbhost}:2377"
                }
            }
        }
    }

    stage('dockerservice') {
        def chk = sh returnStatus: true, script: "docker service ps ${branch}"
        if ( chk != 0 ) {
            def repn = workern + 1
            sh "docker service create --name ${branch} --replicas ${repn} --publish 8080:8080 ${lbhost}:5000/${branch}:${version}"
        } else {
            sh "docker service update --image ${lbhost}:5000/${branch}:${version} ${branch}"
        }
    }

    stage('validation') {
        sleep 10
        def chk = sh returnStdout: true, script: "curl http://${lbhost}:8080/${branch}/"
        def chkver = parseVersion(chk)
        println "Check version: ${chkver}"
        if ( chkver == version ) {
            echo 'Validation: OK'
        } else {
            error 'Application deploy failure'
        }
    }

    stage('pushversion') {
        //sh "git checkout ${branch}"
        sh 'git add gradle.properties'
        sh "git commit -m 'Increment version to ${version}'"
        withCredentials([usernameColonPassword(credentialsId: 'ae917e0e-e1cc-4c9a-b411-f6a371877c5c', variable: 'gitcred')]) {
            sh "git push https://${gitcred}@${repository}"
        }
        sh "git checkout master"
        sh "git pull"
        sh "git merge ${branch}"
        withCredentials([usernameColonPassword(credentialsId: 'ae917e0e-e1cc-4c9a-b411-f6a371877c5c', variable: 'gitcred')]) {
            sh "git push https://${gitcred}@${repository}"
        }
        sh "git tag -a v${version} -m 'Version ${version}'"
        withCredentials([usernameColonPassword(credentialsId: 'ae917e0e-e1cc-4c9a-b411-f6a371877c5c', variable: 'gitcred')]) {
            sh "git push https://${gitcred}@${repository} v${version}"
        }
    }

}
