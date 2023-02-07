setup(){
    load '../../test_helper/bats-support/load'
    load '../../test_helper/bats-assert/load'
    source ../_functions.sh
}

setup_file() {
    cd test/tests/volumes
    go run ../../../cmd/katenary/* convert -f
    helm template chart/volumes --set database.persistence.db.enabled=false> helm.yaml
}

teardown_file() {
    rm -rf chart helm.yaml
}


@test "App name is OK" {
    [ $(yq ".name" chart/volumes/Chart.yaml) == "volumes" ]
}

@test "PVC for mariadb is not set" {
    run get_val "PersistentVolumeClaim" "RELEASE-NAME-db" ".spec.resources.requests.storage"
    assert_output ""
}

@test "database volume should be emptyDir" {
    run get_val "Deployment" "RELEASE-NAME-database" ".spec.template.spec.volumes[0].persistentVolumeClaim"
    assert_output "null"

    run get_val "Deployment" "RELEASE-NAME-database" ".spec.template.spec.volumes[0].emptyDir"
    assert_output "{}"
}

@test "Ensure that nginx has no volume mounted" {
    run get_val "Deployment" "RELEASE-NAME-nginx" ".spec.template.spec.volumes"
    assert_output "null"
}

# vim: ft=bash
