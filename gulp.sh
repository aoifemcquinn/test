#!/bin/bash
#Function to get the current path. Mainly used after changing directory.
function currentLocation() {
  #statements
  echo "Current Location is $1"
  sleep 5s
}

#Checking is there is an input file.
if [ $# -eq 0 ]; then
  echo "Please provide a path to the file you wish to work on."
  exit 1
fi
#Checking if input file exists.
if [ ! -f $1 ] ; then
  echo "Please provide a valid file path."
  exit 1
fi
#Checking if cachingIssue/input exists, if it exists
#Deleting all the files in cachingIssue/input
if [ -d ~/cachingIssue/input ]; then
  rm -r ~/cachingIssue/input/
  echo "Deleting files in input from past runs."
fi
#Checking if cachingIssue/output exists, if it exists
#Deleting all the files in cachingIssue/output
if [ -d ~/cachingIssue/output ]; then
  rm -r ~/cachingIssue/output/
  echo "Deleting files in output from past runs."
fi
#Creating directories if they don't exist.
mkdir -p ~/cachingIssue/input ~/cachingIssue/output
echo "Created input and output folders."
inputFolder=~/cachingIssue/input
outputFolder=~/cachingIssue/output
#Storing the passed file name into a variable.
fileName=$(basename $1 )
folderName="viewer"
warFileName="viewer.war"
if [ ! "$fileName" == "$warFileName" ]; then
  echo "Please provide a valid war file to extract."
  exit 1
fi
echo "Working on file $fileName"
cp $1 $inputFolder
cd $inputFolder
currentLocation $PWD
#Extracting the viewer.war file
mkdir -p $folderName
echo "Extracting contents from $fileName"
cd $folderName
jar -xvf $inputFolder/$fileName
#clear
gulp createBuildNumber
echo "Running gulpFile.js"
buildNum=$(cat build_info.txt)
if [[ ! "$buildNum" ]]; then
    echo $buildNum
    echo "There was a problem with creating your build number"
    exit 1
fi
echo $buildNum
echo "Updating index file with build numbers"
sed -i -e "s|src=\"|src=\"$buildNum\/|g" index.html
sed -i -e "s|href=\"|href=\"$buildNum\/|g" index.html
# <base href="/viewer/" />
sed -i -e "s|$buildNum//viewer/|/viewer/|g" index.html
sed -i -e "s|$buildNum///|//|g" index.html
sed -i -e "s|$buldNumhttps|https|g" index.html
cd js/
echo "Updating js files with build number"
oldPartialString="partials\/"
newPartialString="$buildNum\/partials\/"
grep -rl $oldPartialString . | xargs sed -i "s|$oldPartialString|$newPartialString|g"

echo "updating img string in cp-productPage"

oldImgString="imagePath: " #imagePath:
newImgString="imagePath: \"$buildNum\/\" + " #imagePath: $buildPath + "/" + 
grep -rl $oldImgString . | xargs sed -i "s|$oldImgString|$newImgString|g"

currentLocation $PWD
########
cd ..
cd partials/
echo "updating images link in partials"
oldImagesString="images\/"
newImagesString="$buildNum\/images\/"
grep -rl $oldImagesString . | xargs sed -i "s|$oldImagesString|$newImagesString|g"
oldImgPartialsString="img\/"
newImgPartialsString="$buildNum\/img\/"
grep -rl $oldImgPartialsString .| xargs sed -i "s|$oldImgPartialsString|$newImgPartialsString|g"
########

cd ..
#sleep 1000s
rm viewer/$buildNum/index.html
#rm $buildNum/build_info.txt
mv index.html viewer/
#deleting js folder to replace new js
rm -r viewer/$buildNum/js/
rm -r viewer/$buildNum/partials
mv js viewer/$buildNum
mv partials  viewer/$buildNum/
mv viewer/$buildNum/META-INF viewer/
mv viewer/$buildNum/WEB-INF viewer/
ls
cd viewer
jar -cvfM ../$warFileName .
cd ..
mv $warFileName $outputFolder/$warFileName
#rm -r ./*
#clear
echo "Creating a new war file"
echo "A copy of the zip file is stored in $inputFolder as $fileName"
echo "A new version of the war file sits at $outputFolder as $warFileName"
