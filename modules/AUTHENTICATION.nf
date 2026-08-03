#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process AUTHENTICATION {

    input:
    val download_tools //can be null for interactive mode
    val first_name
    val last_name
    val email
    val institution
    val license

    output:
    val download_tools

    script:
    
    """
    bash ${projectDir}/config_tools_setup/authentication_run.sh \
        "$first_name" \
        "$last_name" \
        "$email" \
        "$institution" \
        "$license" 

    """
}

process AUTHENTICATION_DOWNLOAD {

    publishDir "${projectDir}/config-tools", mode: 'copy'

    input:
    val token

    output:
    path "MSFragger*", emit: msfragger_jar
    path "IonQuant*", emit: ionquant_jar
    path "[dD]ia[tT]racer*", emit: diatracer_jar

    script:
    """
    echo "TOKEN RECEIVED: ${token}"

    USER_TOKEN="${token}"

    MSFRAGGER_VERSION=\$(curl -s https://msfragger-upgrader.nesvilab.org/upgrader/latest_version.php)
    IONQUANT_VERSION=\$(curl -s https://msfragger-upgrader.nesvilab.org/ionquant/latest_version.php)
    DIATRACER_VERSION=\$(curl -s https://msfragger-upgrader.nesvilab.org/diatracer/latest_version.php)

    echo "Downloading MSFragger version: \$MSFRAGGER_VERSION"

    VERSION_ENCODED=\${MSFRAGGER_VERSION// /%20}

    curl --fail --location --output msfragger.zip \
    "https://msfragger-upgrader.nesvilab.org/upgrader/download.php?token=\$USER_TOKEN&download=\${VERSION_ENCODED}%24zip"


    if [ ! -f msfragger.zip ]; then
        echo "ERROR: MSFragger download failed"
        exit 1
    fi

    unzip -q msfragger.zip
    rm msfragger.zip


    echo "Downloading IonQuant version: \$IONQUANT_VERSION"

    IONQUANT_ENCODED=\${IONQUANT_VERSION// /%20}

    curl --fail --silent --show-error --location --output ionquant.zip \
    "https://msfragger-upgrader.nesvilab.org/ionquant/download.php?token=\$USER_TOKEN&download=\${IONQUANT_ENCODED}%24zip"


    if [ ! -f ionquant.zip ]; then
        echo "ERROR: IonQuant download failed"
        exit 1
    fi

    unzip -q ionquant.zip
    rm ionquant.zip

    echo "Downloading DiaTraver version: \$DIATRACER_VERSION"

    DIATRACER_ENCODED=\${DIATRACER_VERSION// /%20}

    curl --fail --silent --show-error --location --output diatracer.zip \
    "https://msfragger-upgrader.nesvilab.org/diatracer/download.php?token=\$USER_TOKEN&download=\${DIATRACER_ENCODED}%24zip"


    if [ ! -f diatracer.zip ]; then
        echo "ERROR: diaTracer download failed"
        exit 1
    fi

    unzip -q diatracer.zip
    rm diatracer.zip


    echo "Searching for JAR files..."

    MSFRAGGER_DIR=\$(find . -maxdepth 1 -type d -name "MSFragger*" | head -n 1)
    IONQUANT_DIR=\$(find . -maxdepth 1 -type d -name "IonQuant*" | head -n 1)
    DIATRACER_DIR=\$(find . -maxdepth 1 -type d \( -name "diaTracer*" -o -name "DiaTracer*" -o -name "diatracer*" \) | head -n 1)


    if [ -z "\$MSFRAGGER_DIR" ]; then
        echo "ERROR: MSFragger jar missing"
        exit 1
    fi

    if [ -z "\$IONQUANT_DIR" ]; then
        echo "ERROR: IonQuant jar missing"
        exit 1
    fi

    if [ -z "\$DIATRACER_DIR" ]; then
        echo "ERROR: DiaTracer jar missing"
        exit 1
    fi

    echo "Found:"
    echo "\$MSFRAGGER_DIR"
    echo "\$IONQUANT_DIR"
    echo "\$DIATRACER_DIR"


    # Move jars into process root so Nextflow can publish them
    #cp -r "\$MSFRAGGER_DIR" .
    #cp -r "\$IONQUANT_DIR" .
    #cp -r "\$DIATRACER_DIR" .


    #echo "Final output:"
    #ls -lh *.jar
    """
}