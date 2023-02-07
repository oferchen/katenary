function get_val() {
    KIND=$1
    NAME=$2
    VAR=$3
    FILE="helm.yaml"

    yq "select(.kind == \"$KIND\" and .metadata.name == \"$NAME\") | ${VAR} " $FILE
}
