#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def licensingInformation(){
    // Print the licensing information
    println file(projectDir + '/config_tools_setup/licence_info/msfragger.txt').text
}

def additionMSFraggerLicensingInformationIonQuant(){
    // Print MSFragger licensing information
    println file(projectDir + '/config_tools_setup/licence_info/additional_msfragger_info.txt').text
}

def addDownloadInformation(){
    def download_first_name = ''
    def download_last_name = ''
    def download_email = ''
    def download_institution = ''
    def license_accept = false
    def download_tools = false

    def configToolsDir = file("${projectDir}/config-tools")

    def ionquant_jar = configToolsDir.exists() && configToolsDir.listFiles()?.any { 
        it.name.startsWith("IonQuant") && it.name.endsWith(".jar") 
    }

    def msfragger_jar = configToolsDir.exists() && configToolsDir.listFiles()?.any { 
        it.name.startsWith("MSFragger") && it.name.endsWith(".jar") 
    }

    def diatracer_jar = configToolsDir.exists() && configToolsDir.listFiles()?.any { 
        it.name.startsWith("diaTracer") && it.name.endsWith(".jar") 
    }

    println ""
    println "=========================================================================="
    println "                       TOOLS AVAILABILITY CHECK"
    println "=========================================================================="
    println ionquant_jar ? "✅ IonQuant : available" : "❌ IonQuant : not available"
    println msfragger_jar ? "✅ MSFragger : available" : "❌ MSFragger : not available"
    println diatracer_jar ? "✅ DiaTracer : available" : "❌ DiaTracer : not available"
    println "\n"

    download_tools = !(ionquant_jar && msfragger_jar && diatracer_jar)

    if (download_tools){
        println "Config tools are not available!\n"
        println "PLEASE ENTER THE CONTACT INFORMATION TO DOWNLOAD:"
        println "First Name:"
        download_first_name = System.in.newReader().readLine()
        println "\nLast Name:"
        download_last_name = System.in.newReader().readLine()
        println "\nEmail:"
        download_email = System.in.newReader().readLine()
        println "\nInstitution:"
        download_institution = System.in.newReader().readLine()

        license_accept = false

        licensingInformation()
        if (System.in.newReader().readLine().toLowerCase().matches("yes|y")){
            license_accept = true
        }
        else{
            license_accept = false
            error "Please accept the licensing information to proceed!"
        }
        
        if (!msfragger_jar){
            additionMSFraggerLicensingInformationIonQuant()
            if (System.in.newReader().readLine().toLowerCase().matches("yes|y")){
                license_accept = true
            }
            else{
                license_accept = false
                error "Please accept the licensing information to proceed!"
            }
        }

    }
    return [
        ionquant_jar: ionquant_jar,
        msfragger_jar: msfragger_jar,
        diatracer_jar: diatracer_jar,
        download_first_name: download_first_name,
        download_last_name: download_last_name,
        download_email: download_email,
        download_institution: download_institution,
        license_accept: license_accept,
        download_tools: download_tools
    ]
}

def token(int attempts = 3){
    if (attempts == 0) {
        error "Too many invalid authentication attempts."
    }
    
    def auth_token = System.in.newReader().readLine()

    if (auth_token ==~ /\d{6}/) {
        println "Authentication code accepted."
        return auth_token
    }

    println "Invalid input. Please enter exactly 6 digits sent to your email.Attempts remaining: ${attempts-1}"

    return token(attempts-1)
}

def checkEmailForToken()
{
    println "Please check your email for the authentication code!"
}
