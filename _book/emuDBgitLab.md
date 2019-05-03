# (PART) Recipes {-}

# Version control of emuDB with git2r and GitLab



This document describes how to do `git` versioning of an emuDB for collaboratively working on a emuDBs. In this short introduction we will focus on using a GitLab instance such as the one provided by the [LRZ](https://www.lrz.de/) https://gitlab.lrz.de/. However, it should also work with most comparable services (Github, BitBucket, etc.) after a few slight ajustments.

The first thing we need to do is install and load the git2r package:


```r
install.packages("git2r")
library("git2r")
```
<!-- load lib -->


And create and load an example emuDB:


```r
library(emuR)
create_emuRdemoData()
db = load_emuDB(file.path(tempdir(), 
                          "emuR_demoData", 
                          "ae_emuDB"),
                verbose = F)
```

As the emuDB is not yet under git version control we will proceed by initializing a new git repository in the emuDB directory:


```r
repo = git2r::init(db$basePath)
repo
```

```
## Local:    /private/var/folders/yk/8z9tn7kx6hbcg_9n4c1sld980000gn/T/Rtmp86jqw6/emuR_demoData/ae_emuDB
## Head:     nothing commited (yet)
```
As can be seen by the above output, the repository currently doesn't have anything commited to it. Before we commit anything to the repo, let us first tell git to ignore the emuDBcache file, as we don't want put this under version control:


```r
gitignorePath = file.path(db$basePath, 
                          ".gitignore")

readr::write_lines(c("*_emuDBcache.sqlite"), 
                   gitignorePath)
```

Now we can add everything to the repository and create our initial commit:


```r
git2r::add(repo, "*")

git2r::commit(repo, 
              message = "init commit")
```

```
## [28948a8] 2019-05-03: init commit
```

The above two commands should be repeated (incl. a new commit message that reflects the current changes made) whenever a new emuDB state should be saved/added to the git repo.

## Using GitLab to host the emuDB

The above examples only work on a local git repo that is located inside of the emuDB directory (contained in a hidden directy called `.git`). Although this is already very benefitial, as we have versioning enabled for our emuDB and can also go back to previous versions, it doesn't utilize one of git's greatest features. Git is able to sync repository states between multiple machines. Here, we will use GitLab to host the emuDB. 

The first thing we will need to do is create a "Personal Access Token" in GitLab so git2r can authenticate you. After logging into your GitLab account navigate to `User Settings -> Access Tokens` and create a new Access Token called `git2r` (choose different name if you wish) with `Scopes` set to `api` for full read/write access:


<img src="pics/GitLab-AccesToken1.png" width="75%" style="display: block; margin: auto;" />

After you press `Create personal access token` the newly access token will be displayed:

<img src="pics/GitLab-AccesToken2.png" width="75%" style="display: block; margin: auto;" />

Copy the token and create an environment variable called `GITLAB_PAT` that git2r can use to authenticate you:


```r
Sys.setenv(GITLAB_PAT = "8NY9niB75s7XFUy73dwR") # replace with own token
```

**SECURITY WARNING: The access key gives users full access to all your GitLab projects! Hence, it should be treated like your password! Do not share or loose! If you accidentally share or loose your key, revoke the token immediately and create a new one!**

Next you need to create a new project in GitLab under `Projects -> New project`

<img src="pics/GitLab-newProject1.png" width="75%" style="display: block; margin: auto;" />

that has the same name as the emuDB:

<img src="pics/GitLab-newProject2.png" width="75%" style="display: block; margin: auto;" />

The URL of the GitLab should now be something like: `https://gitlab.lrz.de/raphywink/ae_emudb.git`. Next, we will add the newly created remote repo to the configuration of the local repo and push the local changes to the remote:


```r
git2r::remote_add(repo = repo, 
                  name = "origin",
                  url = "https://gitlab.lrz.de/raphywink/ae_emudb.git")

git2r::push(repo, 
            name = "origin",
            refspec = "refs/heads/master",
            #set_upstream = TRUE,
            credentials = git2r::cred_token(token = "GITLAB_PAT")
            )
```

## TODO

- try to get git-lsf to work with git2r
