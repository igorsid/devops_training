// registry_ip, version -- defined in project params
def repository = 'github.com/igorsid/devops_training.git'
def branch = 'task10'
def chef_cfg = '/vagrant/chef-repo/.chef'

node('master') {

    stage('check') {
        println "registry_ip: ${registry_ip}"
        println "version: ${version}"
    }

    stage('git_pull') {
        git url: "https://${repository}", branch: branch, changelog: false, poll: false
    }

    stage('chef_cfg') {
        sh "cp -r ${chef_cfg} ./"
        sh 'knife ssl fetch'
    }

    stage('upd_attrs') {
        def txtin = readFile "cookbooks/${branch}/attributes/default.rb"
        def txtout = txtin.split('\n')
            .collect() { line ->
                line.contains("'registry_ip'") ? "node.default['registry_ip']='${registry_ip}'" :
                line.contains("'version'") ? "node.default['version']='${version}'" :
                line
            }
            .join('\n') + '\n'
        writeFile file: "cookbooks/${branch}/attributes/default.rb", text: txtout
    }

    stage('chef_upload') {
        sh 'knife environment from file environments/testing.json'
        sh 'knife role from file roles/webapps.json'
        sh 'knife cookbook upload task10'
        sh 'knife node environment set worker testing'
        sh 'knife role run_list set webapps "recipe[task10]"'
        sh 'knife node run_list set worker "role[webapps]"'
    }

    stage('git_push') {
        sh "git add cookbooks/${branch}/attributes/default.rb environments/testing.json"
        sh "git commit -m 'Switch cookbook to version ${version}'"
        withCredentials([usernameColonPassword(credentialsId: '27801929-2c6d-4353-8653-01e4b5cc00fc', variable: 'gitcred')]) {
            sh "git push https://${gitcred}@${repository}"
        }
    }

    stage('chef_client') {
        sh 'sudo chef-client'
    }

}
