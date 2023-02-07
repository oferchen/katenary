
setup(){
    load '../../test_helper/bats-support/load'
    load '../../test_helper/bats-assert/load'
    source ../_functions.sh
}

setup_file() {
    cd test/tests/basics
    go run ../../../cmd/katenary/* convert -f
    helm template chart/basics > helm.yaml
}

teardown_file() {
    rm -rf chart helm.yaml
}

@test "Generate with helm" {
    helm template chart/basics
}

@test "App name is OK" {
    [ $(yq ".name" chart/basics/Chart.yaml) == "basics" ]
}
    
@test "Helm content is ok" {
    run yq 'select(.kind == "Deployment")| .metadata.name' helm.yaml
    assert_output "RELEASE-NAME-nginx"
   
}
@test "Ensure that the container name is set to nginx" {
    run get_val "Deployment" "RELEASE-NAME-nginx" ".spec.template.spec.containers[0].name"
    assert_output "nginx"
}

@test "Ensure that the container port is set to 80" {
    run get_val "Deployment" "RELEASE-NAME-nginx" ".spec.template.spec.containers[0].ports[0].containerPort"
    assert_output "80"
}


# vim: ft=bash
