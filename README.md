# Deployment of the gyman projects

### This project assumes that:

  - you have locally installed capistrano and capifony 

    ```
    sudo gem install capifony
    ```

  - destination server meets all the requirements of installed projects (proper java, ruby, nodejs, npm, compass and all other dependencies are in correct versions)
  - you (as a local user) have added your ssh key to deployment user's (remote user on server) ~/.ssh/authorized_keys
  - remote deployment user has access tru github to all project repositories and you added deployment user authorization key to github user [[how to do this?]](https://developer.github.com/guides/managing-deploy-keys/#deploy-keys)
  - remote server has free disk space for new release (usually 1-2 GB)
  
### What is capistrano and capifony and why are they important?

Capistrano is a Ruby gem that provides continuous deployment of project. It means that you can run deployment as many times as you want and you always got the same result. It's runned locally on your machine, connects tru ssh to destination server, checkouts code base from configured github repository and performs commands configured in app/config/deploy.rb file.

Capistrano manages for you also multiple releases: you can keep as many previous releases as you want and also rollback to them if something is wrong with a new one, seamlessly for users visiting site. Last thing is that you can keep files and directories shared between releases, for example config files, upload directories etc. [[check capistrano docs]](http://capistranorb.com/)

Capifony adds a Symfony2 flavour to capistrano, fits to it structure and gives you remote access to symfony console tool. [[check capifony docs]](http://capifony.org/)

Capistrano builds in every project a specific structure of directories:

```
/vhosts/<project>/
  |
  |===> releases/
  |      |
  |      |==> 20140910200000
  |      |     |
  |      |     |=> @app/config/parameters.yml // symlink to /vhosts/shared/app/config/parameters.yml
  |      |     |=> app/cache
  |      |     |=> ...
  |      |==> 20141010200000
  |      |==> 20141110200000
  |
  |===> shared/
  |      |
  |      |==> app/config/parameters.yml // editable file shared between all releases
  |      |==> web/uploads // shared directory for uploaded files, for all releases
  |
  |===> @current/ // symlink to last succesful release's directory
```

We do not share vendors on purpose - different codebases may require different vendor versions, quick roleback should require installing vendors again. According to this rule, we cannot also share cache/ directory.

### To easily deploy a project:

1. Checkout this project to directory

  ```
  > git clone ssh://git@github.com/gyman/deploy.git ~/deploy
  ```

2. Using console cd to directory and run deployment

  ```
  > cd ~/deploy
  > cap <server> <project> deploy
  ```
  
  you can also easily specify a branch to deploy from (configuration has pre-configured default branches for every project, but for developers could be easier to test specific branch or deployer could deploy chosen git tag)
  
  ```
  > cap -s branch=<branch name> <server> <project> deploy
  ```
  
  A real life example would be:
  
  ```
  > cap -s branch=<branch-name> testing application deploy
  ```

3. After the script finishes it should look similar to this:

  ```
uirapuru@uirapuru-desktop /v/w/gyman.deploy:master> 
cap production application deploy
--> Updating code base with checkout strategy
--> Creating cache directory................................✔
--> Creating symlinks for shared directories................✔
--> Creating symlinks for shared files......................✔
--> Normalizing asset timestamps............................✔
--> Downloading Composer....................................✔
--> Installing Composer dependencies........................✔
--> Warming up cache........................................✔
--> Clear controllers.......................................✔
--> Setting permissions.....................................✔
--> Successfully deployed!
--> Created index.php
--> Apache successfully restarted
  ```
  
### Other useful tasks:

lists available tasks (also added by capifony extension to reach ./app/console of the project and defined by user in ./app/config/deploy.rb):

```
cap -vT
```

clean ups old releases from server

```
cap <server> <project> deploy:cleanup
```

### Currently configured servers

  1. testing
  2. production

### Currently configured projects

  1. application
  2. webpage

### How to debug deployment errors and potential problems

Edit ./app/config/deploy.rb file and uncomment this line before running deployment:

```
#logger.level = Logger::MAX_LEVEL
```

For debugging purposes always log in on server tru ssh as a deployment user (configured in the same file)

Also remember that specific projects have some individual task running npm, bower etc. that are in some cases muted from displaying errors (--silent, --quiet parameters).

Always rememeber that after unsuccesful deployment, release is removed.
After succesfull deployment capistrano starts "deploy:clenup" task, which leaves only 3 last succesful deployments.
