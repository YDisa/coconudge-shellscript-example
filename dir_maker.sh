#!/bin/bash

isLoop=true
# 서버명칭
server_name=""
npmToken=""
while [ $isLoop == true ]; do
    echo "구성할 디렉토리 구성의 서버 명칭(영문으로만)"
    read inputName
    # 영문체크
    if [[ "$inputName" =~ ^[a-zA-Z]*$ ]] ; then
        echo "$inputName 서버 디렉토리를 구성하시겠습니까?(y/n)"
        read y_or_n
    else
        echo "영문으로만 작성해주세요."
        continue
    fi
    echo "NPM token을 입력해주세요."
    read inputNpmToken
    npmToken="${inputNpmToken}"

    #y체크
  if [ $y_or_n = "y" ]; then
    isLoop=false
    server_name="${inputName}"
  else
    echo "y를 입력받지않아 종료합니다."
    exit 0
  fi
done

echo "[${server_name}] 서버명으로 디렉토리 구성을 시작합니다"

#현재 실행한 디렉토리 가져오기.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  TARGET="$(readlink "$SOURCE")"
  if [[ $SOURCE == /* ]]; then
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    SOURCE="$DIR/$TARGET"
  fi
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

echo "현재 디렉토리 절대경로 : ${DIR}"

# 프로젝트 root 디렉토리
project_root_dir="${DIR}/${server_name}_app"
# 프로젝트 서버 디렉토리
project_api_dir="${project_root_dir}/${server_name}-server"
# 프로젝트 서버 - docker file upload 디렉토리
project_api_upload_dir="${project_api_dir}/upload"
# 프로젝트 프론트 빌드가 올라갈 디렉토리
project_front_dir="${project_root_dir}/${server_name}-front"
# 프로젝트 관리자 빌드가 올라갈 디렉토리
project_admin_dir="${project_root_dir}/${server_name}-admin"

# 프로젝트 root dir 체크 및 생성
if [ ! -d $project_root_dir ]; then
  mkdir $project_root_dir
fi
# 프로젝트 api dir 체크 및 생성
if [ ! -d $project_api_dir ]; then
  mkdir $project_api_dir
fi
# 프로젝트 api upload dir 체크 및 생성
if [ ! -d $project_api_upload_dir ]; then
  mkdir $project_api_upload_dir
fi
# 프로젝트 front dir 체크 및 생성
if [ ! -d $project_front_dir ]; then
  mkdir $project_front_dir
fi
# 프로젝트 admin dir 체크 및 생성
if [ ! -d $project_admin_dir ]; then
  mkdir $project_admin_dir
fi

echo "디렉토리 생성 완료"

echo ".npmrc 파일 생성"

#echo "//npm.pkg.github.com/:_authToken=${npmToken}" > "${project_root_dir}/.npmrc"
echo "//npm.pkg.github.com/:_authToken=${npmToken}" > "${$HOME}/.npmrc"

echo ".npmrc 파일 생성 완료"

exit 0