#----------------------------------------------------------------------------
# RSuite
# Copyright (c) 2017, WLOG Solutions
#
# Tools for building source packages into binary form.
#----------------------------------------------------------------------------

#'
#' Builds source packages provided as data frame in available.packages form
#' 
#' It will create temporary project, copy packages into it and build project env
#'    and packages itself. It will put temporary project packages generated into
#'    destination folder.
#' 
#' @param avail_pkgs pacakges to build as data.frame of available.packages form.
#' @param dest_dir folder to put binary package into. Must exist. (type: character)
#' @param pkg_type type of package to build. Must not be source. (type: character)
#' @param params rsuite_prj_params object to get repository settings from. Dependencies
#'    will be resolved from the specified repositories.
#' @param rver version of R to build packages for. (type: characted, default: params$r_ver) 
#' 
build_source_packages <- function(avail_pkgs, dest_dir, pkg_type, params, rver = params$r_ver) {
  stopifnot(is.data.frame(avail_pkgs) && "Package" %in% colnames(avail_pkgs))
  stopifnot(dir.exists(dest_dir))
  stopifnot(pkg_type != "source")
  
  pkg_loginfo("===> Building %s source packages into %s type: %s ...", 
              nrow(avail_pkgs$Package), pkg_type, paste(avail_pkgs$Package, collapse = ", "))
  
  tmp_path <- tempfile("src_build_temp")
  cont_dir <- rsuite_contrib_url(tmp_path, pkg_type, rver)
  dir.create(cont_dir, recursive = T, showWarnings = F)
  on.exit({ unlink(tmp_path, recursive = T, force = T) }, add = TRUE)
  
  dloaded <- pkg_download(avail_pkgs, dest_dir = cont_dir)
  
  # prepare project to build packages
  bld_prj <- prj_start(name = basename(tempfile(pattern = "srcrepo_proj_")), 
                       path = tempdir(),
                       skip_rc = T)
  on.exit({ unlink(bld_prj$path, recursive = T, force = T) }, add = TRUE)
  
  prj_config_set_rversion(rver = rver, prj = bld_prj)
  prj_config_set_repo_adapters(make_detached_repos(params), prj = bld_prj)
  bld_params <- bld_prj$load_params()
  
  # unpack them into project
  lapply(X = dloaded$Path,
         F = function(src_archive) {
           if (grepl("[.]zip$", src_archive)) {
             utils::unzip(src_archive, exdir=bld_params$pkgs_path)
           } else {
             utils::untar(src_archive, exdir=bld_params$pkgs_path)
           }
         })
  
  unlink(list.files(bld_params$script_path, pattern = ".+[.]R$", full.names = T),  force = T) # not to include default packages
  prj_install_deps(bld_prj) # build enbvironment
  
  # build packages itself
  build_install_tagged_prj_packages(bld_params, # from 12_build_install_prj_pacakges.R
                                    revision = NULL,
                                    pkg_type)
  
  res_url <- sprintf("file:///%s",
                     rsuite_contrib_url(bld_params$irepo_path, 
                                        type = pkg_type, 
                                        rver = rver))
  res_avails <- versions.get_available_pkgs(avail_pkgs$Package, res_url)
  failed_pkgs <- setdiff(avail_pkgs$Package, res_avails$Package)
  assert(!length(failed_pkgs),
         "Failed to build packages for %s type: %s",
         pkg_type, paste(failed_pkgs, collapse = ", "))
  
  pkg_download(res_avails, 
               dest_dir = rsuite_contrib_url(dest_dir, pkg_type, rver))
  
  pkg_loginfo("===> Building %s source packages into %s type: %s ... done", 
              nrow(avail_pkgs$Package), pkg_type, paste(avail_pkgs$Package, collapse = ", "))
}

