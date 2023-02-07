setup(){
    load '../../test_helper/bats-support/load'
    load '../../test_helper/bats-assert/load'
    source ../_functions.sh
}

setup_file() {
    cd test/tests/commons
    go run ../../../cmd/katenary/* convert -f
    helm template chart/commons > helm.yaml
}

teardown_file() {
    rm -rf chart helm.yaml
}

@test "App name is OK" {
    [ $(yq ".name" chart/commons/Chart.yaml) == "commons" ]
}
    
@test "Ensure initContainers exists to wait the database" {
    run get_val "Deployment" "RELEASE-NAME-app" ".spec.template.spec.initContainers[0].name"
    assert_output "check-database"
}

@test "Ensure that the port label is used" {
    run get_val "Deployment" "RELEASE-NAME-database" ".spec.template.spec.containers[0].ports[0].containerPort"
    assert_output "3306"
}

@test "Ensure that the environment variable is set to RELEASE-NAME-database" {

    run get_val "Deployment" "RELEASE-NAME-app" ".spec.template.spec.containers[0].env[0].name"
    assert_output "DB_HOST"

    run get_val "Deployment" "RELEASE-NAME-app" ".spec.template.spec.containers[0].env[0].value"
    assert_output "RELEASE-NAME-database"
}

# vim: ft=bash
