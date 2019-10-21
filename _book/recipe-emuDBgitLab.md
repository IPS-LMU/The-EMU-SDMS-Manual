# Version control of emuDBs with Git, Git LFS and GitLab



This document describes how to do Git versioning of an emuDB for collaboratively working on a emuDB. In this short introduction we will focus on using a GitLab instance such as the one provided by the [LRZ](https://www.lrz.de/) (https://gitlab.lrz.de/). However, it should generalize to most comparable services (Github, BitBucket, etc.) with a few slight adjustments. As we will be using Git as well as a Git extension called Git Large File Storage (LFS), please be sure you have these installed on your system. For information on how to install these on your system see: 

- https://git-scm.com/
- https://git-lfs.github.com/

## Setup

The first thing we need to do is create and load an example emuDB:


```r
library(emuR)
create_emuRdemoData()
db = load_emuDB(file.path(tempdir(),
                          "emuR_demoData",
                          "ae_emuDB"),
                verbose = F)
```

As the ae emuDB is not yet under Git version control we will proceed by initializing a new Git repository in the emuDB directory. In a terminal (e.g. the Terminal tab in RStudio) type:


```bash
# cd /path/to/emuDB
git init
```

Next, we will set up Git LFS to track the large files of our emuDB (`*.wav`, `*.fms`, `*.dft` and `*.sqlite`). In a terminal (e.g. the Terminal tab in RStudio) type:


```bash
# in the emuDB dir
git lfs install # install lfs 
git lfs track "*.wav"
git lfs track "*.fms"
git lfs track "*.dft"
git lfs track "*.sqlite"
git add .gitattributes # make sure .gitattributes is tracked
```

Now, we will add everything to the Git repository and create our initial commit. In a terminal type:


```bash
# in the emuDB dir
git add *
git commit -am "initial commit"
```

This is it for the local setup of Git + Git LFS. If you just wish to work locally simply repeat the above two commands every time you wish to commit the current state of the emuDB to the repository (don't forget to use a concise commit message).

### Using GitLab to host the emuDB

The above examples only work on a local Git repository that is located inside of the emuDB directory (contained in a hidden directly called `.git`). Although this is already beneficial, as we have versioning enabled for our emuDB and can also go back to previous versions, it doesn't utilize one of Git's most powerful features. Git is able to sync repository states between multiple machines. Here, we will use GitLab to host the emuDB.

Initially you need to create a new project in GitLab under `Projects -> New project`:

<img src="pics/GitLab-newProject1.png" width="75%" style="display: block; margin: auto;" />

that has the same name as the emuDB:

<img src="pics/GitLab-newProject2.png" width="75%" style="display: block; margin: auto;" />

Make sure to change the `Project slug` to match the casing (_emuDB vs. emudb) of the database suffix. The URL of the repository should now be something like: https://gitlab.lrz.de/raphywink/ae_emuDB.git. Next, we will add the newly created remote repo to the configuration of the local repo and push the local changes to the remote. In a terminal type:


```bash
# in the emuDB dir
git remote add origin git@gitlab.lrz.de:raphywink/ae_emuDB.git # change to your URL
git push -u origin master
```

Enter your login credentials and that is it! You now have a local and remote repository that can easily be synced. To push a new local commit to the remote repository simply type:


```bash
# in the emuDB dir
git push
```

If you want to pull any changes from the remote repository simply type:


```bash
# in the emuDB dir
git pull
```

If you get sick of entering your login credentials (I certainly do) see here: https://docs.gitlab.com/ee/ssh/

## Collaborating with others

If you wish others to access and/or collaborate with you on the database you simply have to add them as "Project members" in GitLab. Under `Project -> Settings -> Members` select your colaborator and choose "Maintainer" (read and write access) as their role permission:

<img src="pics/GitLab-addMember.png" width="75%" style="display: block; margin: auto;" />

Once this is set, the collaborator is able to clone the repository using their own credentials:


```bash
git clone git@gitlab.lrz.de:raphywink/ae_emuDB.git
```

### Default work-flow

When collaborating with multiple people it is usually a good idea to do the following:

1.) **every time** before you start working on an emuDB get the newest version:


```bash
# in the emuDB dir
git pull
```

2.) once you have made changes that you wish to share, create a new commit and push it to the remote repository so the others can access your changes:


```bash
# in the emuDB dir
git commit -am "added autobuild links from ORT to KAN" # change message accordingly
git push
```

### What about my R scripts / other files?

Although ultimately up to the user (the possibilities with Git are basically endless), we recommend keeping the analysis scripts separate from the emuDB for a better separation of concerns (e.g. you might want to share your database but not your "messy" analysis script :-)). This can for example be done using a new R Studio project (`File -> New Project...` in R Studio) which once again is put under Git version control (usually no Git-LFS necessary). If a combination of the emuDB and the analysis Project is desired I would recommend looking into Git submodules: https://git-scm.com/book/en/v2/Git-Tools-Submodules


