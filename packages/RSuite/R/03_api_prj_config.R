#----------------------------------------------------------------------------
# RSuite
# Copyright (c) 2017, WLOG Solutions
#
# Package API related to configuration of projects.
#----------------------------------------------------------------------------

#'
#' Updates project configuration to use only specified repository adapters.
#'
#' After project configuration have been changed repository adapters are
#' initialized on the project.
#'
#' For dependencies detection repository adapters will be used in the same
#' order as passed in names.
#'
#' @param repos vector of repository adapters configuration to use by the project.
#'    Each should be in form <repo_adapter_name>[<arg>]. They should be all
#'    registered. (type: character)
#' @param prj project object to update configuration for. If not passed will use loaded
#'    project or default whichever exists. Will init default project from working
#'    directory if no default project exists. (type: rsuite_project, default: NULL)
#'
#' @export
#'
prj_config_set_repo_adapters <- function(repos, prj = NULL) {
  assert(!missing(repos) && is.character(repos),
         "character(N) vector expected for repos")

  known_ra_names <- reg_repo_adapter_names()
  names <- names(parse_repo_adapters_spec(repos))
  assert(all(names %in% known_ra_names),
         "Unknown repo adapter names detected: %s",
         paste(setdiff(names, known_ra_names), collapse = ", "))

  prj <- safe_get_prj(prj)

  params_file <- file.path(prj$path, 'PARAMETERS')
  params_dt <- read.dcf(params_file)
  repos_val <- paste(repos, collapse = ", ")
  if (!('Repositories' %in% colnames(params_dt))) {
    params_dt <- cbind(params_dt, data.frame(Repositories = repos_val))
  } else {
    params_dt[, 'Repositories'] <- repos_val
  }
  write.dcf(params_dt, file = params_file)

  params <- prj$load_params()
  for(ra_name in names) {
    repo_adapter <- find_repo_adapter(ra_name)
    stopifnot(!is.null(repo_adapter))

    ra_info <- repo_adapter_get_info(repo_adapter, params)
    if (!ra_info$readonly) {
      mgr <- repo_adapter_create_manager(repo_adapter, params = params)
      repo_manager_init(mgr)
      repo_manager_destroy(mgr)
    }
  }
}


#'
#' Updates project configuration to use specified R Version.
#'
#' @param rver R version to be used by the project. (type: character)
#' @param prj project object to update configuration for. If not passed will use loaded
#'    project or default whichever exists. Will init default project from working
#'    directory if no default project exists. (type: rsuite_project, default: NULL)
#'
#' @export
#'
prj_config_set_rversion <- function(rver, prj = NULL) {
  assert(is_nonempty_char1(rver), "Non empty character(1) expected for rver")
  
  tryCatch({
    get_rscript_path(rver)
  }, error = function(e) {
    assert(FALSE, "Could not find valid R %s in path", rver)
  })
  
  prj <- safe_get_prj(prj)
  
  params_file <- file.path(prj$path, 'PARAMETERS')
  params_dt <- read.dcf(params_file)
  if (!('RVersion' %in% colnames(params_dt))) {
    params_dt <- cbind(params_dt, data.frame(RVersion = majmin_rver(rver)))
  } else {
    params_dt[, 'RVersion'] <- majmin_rver(rver)
  }
  write.dcf(params_dt, file = params_file)
  
  pkg_loginfo("Package R version set to %s", params_dt[1, 'RVersion'])
}