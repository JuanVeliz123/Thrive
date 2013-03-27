#############
# Constants #
#############

$DIR = Split-Path $MyInvocation.MyCommand.Path

$TOOLCHAIN_TEMPLATE = Join-Path $DIR toolchain_win.cmake.in


#################
# Include utils #
#################

. (Join-Path $DIR utils.ps1)


###################
# Check for CMake #
###################

if (-Not (Get-Command cmake -errorAction SilentlyContinue))
{
    [Windows.Forms.MessageBox]::Show(
        “Could not find CMake. Please install or reinstall it and make sure to check `"Add CMake to system PATH`" during installation.”, 
        “CMake not found”, 
        [Windows.Forms.MessageBoxButtons]::OK, 
        [Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}


##################################
# Ask for MinGW installation dir #
##################################

if ($env:username -eq "Ben") {
    $MINGW_ENV = Join-Path $DIR test_win
}
else {
    $MINGW_ENV = Select-Directory -Title "Select installation directory for build environment" -Directory $DIR
}


If ([string]::IsNullOrEmpty($MINGW_ENV)) {
    exit 1
}

mkdir (Join-Path $MINGW_ENV cmake) -force
mkdir (Join-Path $MINGW_ENV install) -force


##################################
# Configure CMake toolchain file #
##################################

$ESCAPED_MINGW_ENV = $MINGW_ENV.replace("\", "/")

$ARGUMENTS = "-DTOOLCHAIN_TEMPLATE=$TOOLCHAIN_TEMPLATE",
             "-DMINGW_ENV=$ESCAPED_MINGW_ENV",
             "-P",
             "$DIR/configure_toolchain.cmake"

& cmake $ARGUMENTS


#####################
# Install libraries #
#####################

$LIBRARIES = "7zip", "mingw", "boost", "ogre"

foreach ($LIBRARY in $LIBRARIES) {
    $INSTALL_SCRIPT = Join-Path $DIR (Join-Path $LIBRARY install.ps1)
    & $INSTALL_SCRIPT $MINGW_ENV
}