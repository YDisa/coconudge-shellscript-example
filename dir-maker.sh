#!/bin/bash

isLoop=true
project_name=""
npm_token=""
domain_url=""
while [ $isLoop == true ]; do
    echo "생성할 디렉토리의 프로젝트명을 입력주세요."
    read input
    if [[ $input =~ ^[a-zA-Z]*$ ]]; then
        echo "도메인을 입력해주세요.ex)example.com"
        read inputDomainUrl
        if [[ "$inputDomainUrl" =~ ([a-z0-9\-]+\.){1,2}[a-z]{2,4} ]]; then
            echo "생성할 npm token을 입력해주세요."
            read inputNpmToken
            echo "<${input}> 디렉토리와 <${inputDomainUrl}> 도메인으로 셋팅을 할까요?(y/n)"
            read y_or_n
            if [ "$y_or_n" == "y" ]; then
                isLoop=false
                project_name=$input
                npm_token=$inputNpmToken
                domain_url=$inputDomainUrl
            else
                echo "y가 아니기에 스크립트를 종료합니다."
                exit 0
            fi
        else
            echo "도메인 형식이 아닙니다."
            exit 1
        fi
        
    else
        echo "영문으로만 작성해주세요."
        continue
    fi
done 

echo "${project_name}"

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

project_root_dir="$DIR/${project_name}"
project_api_dir="$project_root_dir/${project_name}-server"
project_front_dir="$project_root_dir/${project_name}-front"
project_admin_dir="$project_root_dir/${project_name}-admin"

if [ ! -d "$project_root_dir" ]; then
    mkdir $project_root_dir  
fi
if [ ! -d "$project_api_dir" ]; then
    mkdir $project_api_dir  
fi
if [ ! -d "$project_front_dir" ]; then
    mkdir $project_front_dir  
fi
if [ ! -d "$project_admin_dir" ]; then
    mkdir $project_admin_dir  
fi

# npmrc_file_dir="$HOME/.npmrc"
npmrc_file_dir="$DIR/.npmrc"

if [ ! -d "$npmrc_file_dir" ]; then
    echo "//npm.pkg.github.com/:_authToken=${npm_token}" > $npmrc_file_dir
fi

echo "디렉토리 셋팅이 완료되었습니다."

echo "nginx 설치와 셋팅을 시작합니다"
if which nginx > /dev/null; then
	echo "이미 nginx가 설치되어있습니다."
    nginx -v
else
    echo "nginx 설치를 시작합니다."
	apt -y install nginx || echo "nginx 설치에 실패했습니다." && exit
fi

# yarn || echo "yarn 설치에 실패했습니다." && exit
yarn add moment || echo "yarn 설치에 실패했습니다."

# nginx_config_dir="/etc/nginx/sites-available/default"
nginx_config_dir="./test"
copy_config_dir="$HOME/nginx_config_copy"

echo "nginx 기본 config 파일 복제"
cp $nginx_config_dir $copy_config_dir
rm $nginx_config_dir
echo "nginx 기본 config 파일 삭제완료"

echo "
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        server_name api.${domain_url};

        # if (\$http_x_forwarded_proto = 'http'){
        #         return 301 https://\$host\$request_uri;
        # }
        location / {
            proxy_set_header Upgrade $\http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header X-Forwarded-For \$remote_addr;
            proxy_set_header Host \$http_host;
            proxy_pass http://127.0.0.1:3000;
        }
    }
    server {
        listen 80;
        listen [::]:80;

        server_name ${domain_url} www.${domain_url};

        # if (\$http_x_forwarded_proto = 'http'){
        #         return 301 https://\$host\$request_uri;
        # }
        root ${project_front_dir};
        index index.html;

        location / {
            try_files \$uri \$uri/ /index.html;
        }
    }

    server {
        listen 80;
        listen [::]:80;

        server_name admin.${domain_url};

        # if (\$http_x_forwarded_proto = 'http'){
        #         return 301 https://\$host\$request_uri;
        # }
        root ${project_admin_dir};
        index index.html;

        location / {
            try_files \$uri \$uri/ /index.html;
        }
    }
" > ./nginx_config

sudo systemctl restart nginx.service

echo "설정완료!"
exit 0