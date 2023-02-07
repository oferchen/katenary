setup(){
    load '../../test_helper/bats-support/load'
    load '../../test_helper/bats-assert/load'
    source ../_functions.sh
}

setup_file() {
    cd test/tests/dependencies
    go run ../../../cmd/katenary/* convert -f
    cd chart/dependencies && helm dep up && cd ../.. 
    helm template chart/dependencies --set database.persistence.db.enabled=true > helm.yaml
}

teardown_file() {
    rm -rf chart helm.yaml
}


@test "App name is OK" {
    [ $(yq ".name" chart/dependencies/Chart.yaml) == "dependencies" ]
}

@test "Mariadb is deployed" {
    run get_val "StatefulSet" "RELEASE-NAME-mariadb-galera" ".metadata.name" "helm.yaml"
    assert_output "RELEASE-NAME-mariadb-galera"
}

@test "Assert that init container checks RELEASE-NAME-mariadb-galera" {
    run get_val "Deployment" "RELEASE-NAME-app" ".spec.template.spec.initContainers[0].command" "helm.yaml"
    assert_output --partial "nc -z RELEASE-NAME-mariadb-galera 3306"
}


# vim: ft=bash
