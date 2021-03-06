#----------------------------------------------------------------------------
# RSuite
# Copyright (c) 2017, WLOG Solutions
#
# Package initialization.
#----------------------------------------------------------------------------

.onLoad <- function(libpath, pkgname) {
  if (length(logging::getLogger()[['handlers']]) == 0) {
    logging::addHandler(logging::writeToConsole, level = "FINEST")
  }

  rsuite_register_repo_adapter(repo_adapter_create_cran(name = "CRAN"))
  rsuite_register_repo_adapter(repo_adapter_create_mran(name = "MRAN"))
  rsuite_register_repo_adapter(repo_adapter_create_url(name = "Url"))
  rsuite_register_repo_adapter(repo_adapter_create_s3(name = "S3"))
  rsuite_register_repo_adapter(repo_adapter_create_dir(name = "Dir"))

  rsuite_register_rc_adapter(rc_adapter_create_svn(name = "SVN"))
  rsuite_register_rc_adapter(rc_adapter_create_git(name = "GIT"))
}
