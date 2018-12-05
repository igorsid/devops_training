import groovy.json.JsonSlurper
def req = "curl http://${registry_ip}:5000/v2/task10/tags/list"
return new JsonSlurper().parseText(req.execute().text).tags
