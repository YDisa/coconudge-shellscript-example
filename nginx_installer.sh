#!/bin/bash

# 패키지 설치를 위해 sudo 권한 필요.
if [ "$EUID" -ne 0 ]
  then echo "sudo 권한으로 실행해주세요."
  exit
fi
echo "nginx 셋팅을 시작합니다."

isLoop=true

# 필요한 정보 입력
domain_url=""
server_name=""
while [ $isLoop == true ]; do
    echo "도메인을 입력해주세요."
    read inputURL
    # 도메인 형식 체크
    if [[ "$inputURL" =~ ([a-z0-9\-]+\.){1,2}[a-z]{2,4} ]] ; then
        echo "구성되어있는 프로젝트 root 디렉토리 명"
        read inputName
        # 영문체크
        if [[ "$inputName" =~ ^[a-zA-Z]*$ ]] ; then
            echo "$inputURL 도메인 과 $inputName 서버로 디렉토리 셋팅하시겠습니까?(y/n)"
            read y_or_n
        else
            echo "영문으로만 작성해주세요."
            continue
        fi
    else
        echo "올바른 도메인이 아닙니다."
        continue
    fi

    #y체크
    if [ $y_or_n = "y" ]; then
        isLoop=false
        domain_url="${inputURL}"
        server_name="${inputName}"
    else
        echo "y를 입력받지않아 종료합니다."
        exit 0
    fi
done

# 프로젝트 root 디렉토리
project_root_dir="$HOME/${server_name}_app"
# 프로젝트 프론트 빌드가 올라갈 디렉토리
project_front_dir="${project_root_dir}/${server_name}-front"
# 프로젝트 관리자 빌드가 올라갈 디렉토리
project_admin_dir="${project_root_dir}/${server_name}-admin"

DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# nginx 설치 체크 및 설치.
# if which nginx >/dev/null; then
# 	echo "이미 nginx가 설치되어있습니다."
#     nginx -v
# else
#     echo "nginx 설치를 시작합니다."
# 	sudo apt -y install nginx || echo "nginx 설치에 실패했습니다." && exit
# fi

# 테스트를 위해 yarn 으로 대체
yarn || echo "yarn 설치에 실패했습니다." && exit
yarn add asdasdasdasd || echo "yarn 설치에 실패했습니다." && exit

# 기존 nginx 파일을 복사.
# ubuntu_nginx_allow_file_dir="/etc/nginx/sites-available/default"
ubuntu_nginx_allow_file_dir="./test"
copy_dir="$HOME/nginx_copy"
if [ ! -d $ubuntu_nginx_allow_file_dir ]; then
    echo "nginx 파일 복사 완료"
    cp $ubuntu_nginx_allow_file_dir $copy_dir
    rm -y ubuntu_nginx_allow_file_dir
else 
    echo "nginx 설치 경로가 다릅니다. 확인 후 다시 실행해주세요."
    exit 0
fi

# 새로운 nginx파일로 대체.
echo -e "
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name api.${domain_url};

    # if (\$http_x_forwarded_proto = 'http'){
    #         return 301 https://\$host\$request_uri;
    # }
    location / {
        proxy_set_header Upgrade \$http_upgrade;
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

" > ${DIR}/nginx_setting

sudo systemctl restart nginx.service || echo "nginx 재시작에 실패했습니다. 로그를 확인해주세요." && exit

echo "설치 및 셋팅 완료"

exit 0