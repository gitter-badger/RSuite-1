#----------------------------------------------------------------------------
# RSuite
# Copyright (c) 2017, WLOG Solutions
#
# Utilities for management of project parameters.
#----------------------------------------------------------------------------

#'
#' @keywords internal
#'
#' Loads project parameters from specified path.
#'
#' @param prj_path path to base directory of project (the one containing
#'   PARAMETERS file). (type: character)
#' @return object of rsuite_project_parameters
#'
load_prj_parameters <- function(prj_path) {
  assert(is.character(prj_path) && length(prj_path) == 1,
         "character(1) expected for prj_path")
  assert(file.exists(file.path(prj_path, 'PARAMETERS')),
         "No project PARAMETERS file found at %s", prj_path)

  dcf <- read.dcf(file.path(prj_path, 'PARAMETERS'))
  
  params <- list(
    prj_path = rsuite_fullUnifiedPath(prj_path),
    rsuite_ver = ifelse('RSuiteVersion' %in% colnames(dcf), dcf[1, 'RSuiteVersion'], NA),
    r_ver = ifelse('RVersion' %in% colnames(dcf), dcf[1, 'RVersion'], current_rver()), # from 97_rversion.R

    # Date of CRAN snapshot to look for dependencies in.
    #  if empty will use official CRAN and newest package versions available
    snapshot_date = ifelse("SnapshotDate" %in% colnames(dcf), dcf[1, 'SnapshotDate'], ''),

    pkgs_path = rsuite_fullUnifiedPath(file.path(prj_path,
                                                 ifelse('PackagesPath' %in% colnames(dcf), dcf[1, 'PackagesPath'], 'packages'))),
    script_path = rsuite_fullUnifiedPath(file.path(prj_path,
                                                   ifelse('ScriptPath' %in% colnames(dcf), dcf[1, 'ScriptPath'], 'R'))),
    irepo_path = rsuite_fullUnifiedPath(file.path(prj_path, "deployment", "intrepo")),

    # Specifies there to put local project environment
    lib_path = rsuite_fullUnifiedPath(file.path(prj_path, "deployment", "libs")),

    zip_version = ifelse('ZipVersion' %in% colnames(dcf), dcf[1, 'ZipVersion'], ''),
    project = ifelse("Project" %in% colnames(dcf), dcf[1, 'Project'], basename(prj_path)),
    artifacts = ifelse("Artifacts" %in% colnames(dcf), dcf[1, 'Artifacts'], ''),

    # repo_adapters to use for the project
    repo_adapters = ifelse('Repositories' %in% colnames(dcf), dcf[1, 'Repositories'], 'CRAN'),

    # This defines which type of packages are expected on the platform
    #   and how to build project packages.
    pkgs_type = ifelse(.Platform$OS.type == "windows", "win.binary", "source"),
    aux_pkgs_type = ifelse(.Platform$OS.type == "windows", "source", "binary"),
    bin_pkgs_type = ifelse(.Platform$OS.type == "windows", "win.binary", "binary")
  )

  params$get_repo_adapter_names <- function(repo_adapter_name, default) {
    specs <- unlist(strsplit(params$repo_adapters, ","))
    return(names(parse_repo_adapters_spec(specs)))
  }

  params$get_repo_adapter_arg <- function(repo_adapter_name, default, ix) {
    specs <- unlist(strsplit(params$repo_adapters, ","))
    parsed_specs <- parse_repo_adapters_spec(specs)
    if (!is.na(ix)) {
      parsed_specs <- parsed_specs[ix]
    }
    arg <- parsed_specs[names(parsed_specs) == repo_adapter_name]
    arg[is.null(arg) || nchar(arg) == 0] <- default
    names(arg) <- NULL
    return(arg)
  }

  params$get_intern_repo_path <- function() {
    intern_mgr <- repo_manager_dir_create(params$irepo_path, params$pkgs_type, params$r_ver)
    repo_manager_init(intern_mgr)
    return(rsuite_fullUnifiedPath(params$irepo_path))
  }

  class(params) <- 'rsuite_project_params'
  return(params)
}
