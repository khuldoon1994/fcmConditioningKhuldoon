# Information for developers #

On this page, you find the most important things around the git workflow in *skfLambMesh* when using the command line, i.e. the Linux shell. Windows users may use **Git BASH** from [here](https://git-for-windows.github.io/) and and use it to execute the listed commands.

## Clone the git repository
In the terminal ...

 1. Go to the directory where you want to save your git-project, e.g.
    ```
    cd ~/workspace
    ```

 2. Clone the git repository:
    ```
    git clone https://collaborating.tuhh.de/M-10/radtke/SiHoFemLab.git
    ```

## Build
Compile with all available option enabled as described [here](INSTALL_Linux.md) for Linux and [here](INSTALL_Windows.md) for Windows. When installing Qt, make sure to enable the Tool **Qt Creator**.

## Set up IDE
Instructions for **Eclipse** can be found [here](doc/ECLIPSE.md)

## Feature branch workflow
Git is a version control system. You can find out more about it [here](https://git-scm.com/).
We use only a small portion of its functionality and follow what is introduced as *GitHub flow* [here](https://about.gitlab.com/2014/09/29/gitlab-flow/).
More details on this *feature branch flow* can be found [here](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow). 

In very short, you can always find out about what's going on using
```
git status
```
Whenever you switch from one branch to another, make sure your *working directory is clean*.
If you start to work on a new feature, create a **branch** with a nice name, e.g.
```
git checkout -b new-feature
```
and tell the remote about it using
```
git push -u origin new-feature
```
Finally, you go into GitLab, see if the branch is there and create a **merge request**. It should start with *WIP* to mark it as work in progress if you don't want it to be merged right away. From here on, you can use the usual git workflow on your branch.


Once the **code review** is done, the branch is merged into the master branch and deleted afterwards. To delete the branch locally, run
```
git fetch -p                # remove the branch origin/new-feature (if it was deleted on the remote)
git branch -d new-feature   # removes the local branch mew-feature
```


## Workflow on your branch
If you add files, use
```
git add filename1 filename2
```
to stage the files. For comitting, use
```
git commit -a -m "Commit messsage"
```
to commit all changes. To commit only changes to certain files use
```
git commit filename1 filename2 -m "Commit message"
```
Before committing, don't forget to check if your code is in line with tha [coding guidelines](CODING_GUIDELINES.md).
If you can, **reference an issue** in your commit message, e.g. *...resolving #42*.

Upload the changes to the remote using
```
git push
```
This should be done frequently to let others know about what is going on. Frequently means something like **as often as possible, say in between hourly and daily**.

To pull changes from the remote (only for the current branch), use
```
git pull
```

If you haven't done so lately, merge the newest feature from the master branch into your branch with
```
git checkout master      # change to branch master
git pull                 # get the changes fromt the remote
git checkout new-feature # change to your branch
git merge master         # merge the changes from the master into your branch
```
Lately means something line **in the past seven days**.

## Useful links
* [A simple git tutorial](http://rogerdudler.github.io/git-guide/)


