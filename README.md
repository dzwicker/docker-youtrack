
# docker-youtrack

*Easy youtrack deployment using docker*

These Dockerfiles allow you to easily build images to deploy your own [youtrack](http://www.jetbrains.com/youtrack/) instance.

## Disclaimer
Besides that, as always, use these scripts with care.

Don't forget to back up your data very often, too.

## Requirements
Docker has to run. It supports many platforms like Ubuntu, Arch Linux, Mac OS X, Windows, EC2 or the Google Cloud.
[Click here](http://docs.docker.io/en/latest/installation/) to get specific infos on how to install on your platform.

## Oh nice! How do I do it?
1. Install docker. [It's not very hard.](http://docs.docker.io/en/latest/installation/)
2. Run it! (Stop with CTRL-C, repeat at pleasure)

  `docker run -t -i -p 8080:8080 dzwicker/docker-youtrack`



Now open your browser and point it to `http://localhost:8080` and rejoice. :)

## Do it as service in ubuntu/debian
1. Create directory to store data
  
  ``` bash
  mkdir -p /var/lib/youtrack
  mkdir -p /var/log/youtrack
  mkdir -p /etc/youtrack
  ```

2. Permissions!

  The Dockerfile creates a youtrack user to run `youtrack` without root permissions. This user has a `UID` of `2000`. Please make sure to add a user to your host system with this `UID` and allow him to read and write to `/var/lib/youtrack`. The name of this host user in not important. (You can use a the user group, too. It has the `GID` of 2000 :)
  
3. Create container!

  ```
    docker create -t -i -p 127.0.0.1:8080:8080 \ 
    	-v /var/lib/youtrack:/var/lib/youtrack \ 
    	-v /var/log/youtrack:/var/log/youtrack \
    	-v /etc/youtrack:/usr/local/youtrack/conf \
    	-v /tmp:/tmp \
    	--name docker-youtrack \
    	dzwicker/docker-youtrack
    ```

4. Create upstart configuration `/etc/init/docker-youtrack.conf`

	``` bash
	description "Docker Youtrack"
	start on filesystem and started docker
	stop on runlevel [!2345]
	respawn
	script
	  /usr/bin/docker start -a docker-youtrack >>/var/log/youtrack/docker-youtrack.log 2>&1
	end script

	```
5. (optional) Setup logrotate e.g. `/etc/logrotate.d/docker-youtrack`


	```
	/var/log/youtrack/*.log
	/var/log/youtrack/hub/*.log 
    /var/log/youtrack/hub/logs/*.log
	/var/log/youtrack/youtrack/*.log 
	/var/log/youtrack/youtrack/logs/*.log 
	/var/log/youtrack/internal/services/bundleProcess/*.log 
	 {
		rotate 7
		daily
		missingok
		notifempty
		sharedscripts
		copytruncate
		compress
	}
	```
6. (optional) Add vhost to nginx

	`mkdir -p /var/log/nginx/your-domain`

	```
	upstream docker-youtrack {
	  server localhost:8080;
	}

	server {
	  listen 80;
	  server_name           your-domain.com;

	  access_log            /var/log/nginx/your-domain/access.log;
	  error_log             /var/log/nginx/your-domain/error.log;

	  proxy_set_header Host       $http_host;   # required for docker client's sake
	  proxy_set_header X-Real-IP  $remote_addr; # pass on real client's IP

	  client_max_body_size 0; # disable any limits to avoid HTTP 413 for large image uploads

	  # required to avoid HTTP 411: see Issue #1486 (https://github.com/dotcloud/docker/issues/1486)
	  chunked_transfer_encoding on;

	  location / {
	    proxy_pass http://docker-youtrack;
	  }

	}
	```
7. Configuring New YouTrack Server
	
	Follow the steps of the installation [instructions for Jetbrains Youtrack](https://confluence.jetbrains.com/display/YTD65/Installing+YouTrack+with+ZIP+Distribution) using paths located under `/var/lib/hub/data`, `/var/lib/hub/backups`, `/var/log/hub`, `/tmp`.
