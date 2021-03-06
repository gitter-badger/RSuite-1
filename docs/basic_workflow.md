# Basic R Suite usage
In this document we present a basic R Suite usage. It covers:

* creating project
* adding custom packages
* building custom packages
* installing dependencies
* developing custom package with `devtools`
* understanding loggers

# Step 1 - start a new project

To create a new project (called `my_project`) we have to issue the following command
```bash
rsuite proj start -n my_project
```

If the folder you working in is not under git/svn control the output should look like this:
```
2017-09-23 16:39:40 INFO:rsuite:Will create project my_project structure for RSuite v0.9.211.
2017-09-23 16:39:40 INFO:rsuite:Project my_project started.
2017-09-23 16:39:40 WARNING:rsuite:Failed to detect RC manager for my_project
```

To avoid warning message you can add `--skip-rc` when calling `rsuite`.

## Step 1.1 - run master file

Every project has a special structure. Lets change path to this project

```bash
cd my_project
dir
```

You should see the following output
```
 Directory of C:\Workplace\Projects\my_project        
                                                      
2017-09-23  16:39    <DIR>          .                 
2017-09-23  16:39    <DIR>          ..                
2017-09-23  16:39                20 .Rprofile         
2017-09-23  16:39                16 config_templ.txt  
2017-09-23  16:39    <DIR>          deployment        
2017-09-23  16:39    <DIR>          logs              
2017-09-23  16:39               371 my_project.Rproj  
2017-09-23  16:39    <DIR>          packages          
2017-09-23  16:39               121 PARAMETERS        
2017-09-23  16:39    <DIR>          R                 
2017-09-23  16:39    <DIR>          tests             
               4 File(s)            528 bytes         
```

In folder `R` there are master scripts - that are execution scripts in our project. R Suite by default creates exemplary script `R\master.R`

```R
# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
	args <- commandArgs(trailingOnly = FALSE)
	script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
	if (!length(script_path)) { return(".") }
	return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()
```

To check if everything is working properly issue the following command

```bash
Rscript R\master.R
```

You should not see any error messages.


# Step 2 - add first package

R Suite forces users to keep logic in packages. To create a package issue the following command

```bash
 rsuite proj pkgadd -n mypackage
```

To check if everything works run the following commands

```bash
  cd packages\mypackage
  dir
```

You should see the following output

```
2017-09-23  16:50    <DIR>          .
2017-09-23  16:50    <DIR>          ..
2017-09-23  16:50                20 .Rprofile
2017-09-23  16:50    <DIR>          data
2017-09-23  16:50               309 DESCRIPTION
2017-09-23  16:50    <DIR>          inst
2017-09-23  16:50    <DIR>          man
2017-09-23  16:50               371 mypackage.Rproj
2017-09-23  16:50                65 NAMESPACE
2017-09-23  16:50                73 NEWS
2017-09-23  16:50    <DIR>          R
2017-09-23  16:50    <DIR>          tests
               5 File(s)            838 bytes
```

# Step 3 - add custom package to master script

Open in any editor `R\master.R` and change it to look like this:

```R
# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
	args <- commandArgs(trailingOnly = FALSE)
	script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
	if (!length(script_path)) { return(".") }
	return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

library(my_package)
```

You can check if your package is visible to your master script by using the following commands

```bash
Rscript R\master.R
```

You will notice an error saying there is no such package as `mypackage`. This is fine because in R you
have to install package to have access to it.

# Step 4 - building custom packages

Adding a package to the project is not enough to use it. You have to build it. You can do this using this command

```bash
rsuite proj build
```

On my computer this command gave the following output

```
2017-09-23 16:55:55 INFO:rsuite:Installing mypackage (for R 3.3) ...
2017-09-23 16:56:00 INFO:rsuite:Successfuly build 1 packages
```

Now you can check if your master script have access to the package `mypackage`

```bash
Rscript R\master.R
```

If everything worked properly you should not see any error messages.

# Step 5 - adding function to a package

Lets add a function `hello_world` to our pacakge `mypackage`. To do this you have to create a new file in folder `packages/mypackage/R/hello_world.R`.
The easiest way to do this is to open `packages/mypackage/mypackage.Rproj` in R Studio. Edit `hello_world.R` to have the following content

```R
#'@export
hello_world <- function(name) {
    print(sprintf("Hello %s!", name))
}
```

Please remember to add `#'@export` if you want to see this function in global namespace.

Now you can change master script by adding one line to it

```R
# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
	args <- commandArgs(trailingOnly = FALSE)
	script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
	if (!length(script_path)) { return(".") }
	return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

library(my_package)

hello_world("John")
```

Lets check if everything works

```bash
Rscript R\master.R
```

As you can see you got an error message that there is no such function as `hello_world`.

# Step 6 - rebuild packages

You have to rebuild packages to have all the functionality available to master scripts.
Run a command

```bash
rsuite proj build
```

And check if `master.R` works

```bash
Rscript R\master.R
```

You should see output with the following line

```
[1] "Hello John!"
```

# Step 7 - adding dependencies 

You can add dependencies to external packages in two ways:

1. In  `DESCRIPTION` file in each package
2. Using `library` or `require` in master scripts.

We **strongly advise** not to use `library` or `require` in master scripts with
external packages. It is possible but does not give user a full control over 
version of external package.

To add dependency to external package we will edit file `packages\mypackage\DESCRIPTION` like this

```
Package: mypackage
Type: Package
Title: What the package does (short line)
Version: 0.1
Date: 2017-09-23
Author: Wit Jakuczun
Maintainer: Who to complain to <yourfault@somewhere.net>
Description: More about what it does (maybe more than one line)
License: What license is it under?
Depends:
    logging,
    data.table (>= 1.10.1)
RoxygenNote: 5.0.1
```


I have added line `data.table (>= 1.10.1)` to Depends section. This means I declared that `mypackage`
depends on `data.table` package in version `1.10.1` or newer. 

Lets rebuild package to have master scripts see the changes

```bash
rsuite proj build
```

The output is

```
2017-09-23 17:15:21 ERROR:rsuite:Some dependencies are not installed in project env: data.table. Please, install dependencies(Call RSuite::prj_install_deps)
ERROR: Some dependencies are not installed in project env: data.table. Please, install dependencies(Call RSuite::prj_install_deps)
```

You can conclude that you have to install dependencies to build your package.


# Step 8 - install dependencies

To install dependecies you have to issue the following command:

```bash
rsuite proj depsinst
```

You should see the following output

```
2017-09-23 17:12:38 INFO:rsuite:Detecting repositories (for R 3.3)...
2017-09-23 17:12:39 INFO:rsuite:Will look for dependencies in ...
2017-09-23 17:12:39 INFO:rsuite:.          MRAN#1 = http://mran.microsoft.com/snapshot/2017-09-23 (win.binary, source)
2017-09-23 17:12:39 INFO:rsuite:Collecting project dependencies (for R 3.3)...
2017-09-23 17:12:39 INFO:rsuite:Resolving dependencies (for R 3.3)...
2017-09-23 17:12:46 INFO:rsuite:Detected 1 dependencies to install. Installing...
2017-09-23 17:12:51 INFO:rsuite:All dependencies successfully installed.
```

From this output you can see that we use `MRAN` as package repository. Moreover R Suite detected 1 dependency to be installed.

You can check if installation succedded by issuing the following command

```bash
rsuite proj build
```

The output you should see if everything worked

```
2017-09-23 17:18:23 INFO:rsuite:Installing mypackage (for R 3.3) ...
2017-09-23 17:18:28 INFO:rsuite:Successfuly build 1 packages
```

Lets check what happens if you run our master script

```bash
Rscript R\master.R
```

The output says that `data.table` was loaded. This is exactly what we wanted to be.

# Step 9 - developing custom package using `devtools`

If you want to develop a package the cycle dev-build can take too long. This is especially important if the packages are bigger.
You can use `devtools` to speedup this process.

To do this edit `R\master.R` like this

```R
# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
	args <- commandArgs(trailingOnly = FALSE)
	script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
	if (!length(script_path)) { return(".") }
	return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

#library(mypackage)
devtools::load_all(file.path(script_path, "../packages/mypackage"))

hello_world("John")
```

We commented line `library(mypackage)` and added a new line
```R
devtools::load_all(file.path(script_path, "../packages/mypackage"))
```

This line uses devtools to dynamically load your package. We are using variable `script_path` which is
auto-initialized by R Suite and is a path pointing to `master.R`.

# Step 10 - loggers in master scripts

R Suite promotes good programming practices and using loggers is one of them. R Suite is based on `logging` package.

Lets update `R/master.R` as follows

```R
# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
	args <- commandArgs(trailingOnly = FALSE)
	script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
	if (!length(script_path)) { return(".") }
	return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

#library(mypackage)
devtools::load_all(file.path(script_path, "../packages/mypackage"))

loginfo("Master info")
logdebug("Master debug")
logwarn("Master warning")
logerror("Master error")

hello_world("John")
```

Lets check how it works

```bash
Rscript R\master.R
```

The output should look like this

```
Loading mypackage
Loading required package: data.table
2017-09-23 17:27:14 INFO::Master info
2017-09-23 17:27:14 WARNING::Master warning
2017-09-23 17:27:14 ERROR::Master error
[1] "Hello John!"
```

As you can see there are logging messages. You can see that debug message is missing. 

# Step 10.1 - controlling loggers level

To see debug logging message you have to edit file `config.txt` in project root folder to 
look like this

```
LogLevel: DEBUG
```

Lets check how it works

```bash
Rscript R\master.R
```

The output should look like this

```
Loading mypackage
Loading required package: data.table
2017-09-23 17:31:22 INFO::Master info
2017-09-23 17:31:22 DEBUG::Master debug
2017-09-23 17:31:22 WARNING::Master warning
2017-09-23 17:31:22 ERROR::Master error
[1] "Hello John!"
```

As you can see now debug logging message is printed.

# Step 10.2 - `logs` folder

Logging messages are stored in `logs` folder in files named with current date.
You can check this by issuing a command

```bash
dir logs
```

The output on my laptop looks like this

```
2017-09-23  17:27    <DIR>          .
2017-09-23  17:27    <DIR>          ..
2017-09-23  17:31               541 2017_09_23.log
```

When you open this log in an editor you should see content similar to this

```
2017-09-23 17:27:14 INFO::Master info
2017-09-23 17:27:14 WARNING::Master warning
2017-09-23 17:27:14 ERROR::Master error
2017-09-23 17:30:54 INFO::Master info
2017-09-23 17:30:54 WARNING::Master warning
2017-09-23 17:30:54 ERROR::Master error
2017-09-23 17:31:06 INFO::Master info
2017-09-23 17:31:06 WARNING::Master warning
2017-09-23 17:31:06 ERROR::Master error
2017-09-23 17:31:22 INFO::Master info
2017-09-23 17:31:22 DEBUG::Master debug
2017-09-23 17:31:22 WARNING::Master warning
2017-09-23 17:31:22 ERROR::Master error
```

As you can see this is very similar to output you saw in console.


# Step 11 - loggers in packages

R Suite allows you to use loggers in your custom packages. Lets open `hello_world.R` and change its content to the following one

```R
#'@export
hello_world <- function(name) {
  pkg_loginfo("Package info")
  pkg_logdebug("Package debug")
  pkg_logwarn("Package warning")
  pkg_logerror("Package error")

  print(sprintf("Hello %s!", name))
}
```

You can check how it works by issuing this command

```bash
Rscript R\master.R
```

The output you should see

```
Loading mypackage
Loading required package: data.table
2017-09-23 17:37:52 INFO::Master info
2017-09-23 17:37:52 DEBUG::Master debug
2017-09-23 17:37:52 WARNING::Master warning
2017-09-23 17:37:52 ERROR::Master error
2017-09-23 17:37:52 INFO:mypackage:Package info
2017-09-23 17:37:52 DEBUG:mypackage:Package debug
2017-09-23 17:37:52 WARNING:mypackage:Package warning
2017-09-23 17:37:52 ERROR:mypackage:Package error
[1] "Hello John!"
```

As you can see there are messages from your package. They are marked with package name `mypackage`. Please also note that
as you used `devtools` in your master script you did not have to build package to see the changes.

# Step 12 - prepare deployment package

We can now prepare a deployment package to ship our project on a production. To do this you have to first remove `devtools` from `master.R`

```R
# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
	args <- commandArgs(trailingOnly = FALSE)
	script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
	if (!length(script_path)) { return(".") }
	return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

library(mypackage)

loginfo("Master info")
logdebug("Master debug")
logwarn("Master warning")
logerror("Master error")

hello_world("John")
```

Now you have to install dependecies

```bash
rsuite proj depsinst
```

As you did not add any new dependencies R Suite smartly understands it and do not repeat lengthy dependencies installation phase.

Lets build our custom packages

```bash
rsuite proj build
```

You should see the following output

```
2017-09-23 17:44:20 INFO:rsuite:Installing mypackage (for R 3.3) ...
2017-09-23 17:44:25 INFO:rsuite:Successfuly build 1 packages
```

To build a deployment package you use command

```bash
rsuite proj zip
```

You can see that if the project is not under version controll the command returns error. You have to explicitly give version number for your deployment package

```bash
rsuite proj zip --version=1.0
```

The output should be like this

```
2017-09-23 17:49:01 INFO:rsuite:Installing mypackage (for R 3.3) ...
2017-09-23 17:49:06 INFO:rsuite:Successfuly build 1 packages
2017-09-23 17:49:06 INFO:rsuite:Preparing files for zipping...
2017-09-23 17:49:07 INFO:rsuite:... done. Creating zip file my_project_1.0x.zip ...
2017-09-23 17:49:08 INFO:rsuite:Zip file created: C:/Workplace/Projects/my_project/my_project_1.0x.zip
```

You have crated file `my_project_1.0x.zip` that contains all information necessary to run your solution on a production environment.

# Step 13 - running deployment package

To test if the deployment package is working you can extract `my_project_1.0x.zip` created in previous step in a new folder say `prod`.
Now you can run your solution with the command

```bash
Rscript my_project\R\master.R
```

The output you should see

```
2017-09-23 17:53:34 INFO::Master info
2017-09-23 17:53:34 WARNING::Master warning
2017-09-23 17:53:34 ERROR::Master error
2017-09-23 17:53:34 INFO:mypackage:Package info
2017-09-23 17:53:34 WARNING:mypackage:Package warning
2017-09-23 17:53:34 ERROR:mypackage:Package error
[1] "Hello John!"
```

As you can see the output is exactly the same you would expect.
