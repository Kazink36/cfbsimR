#' NCAAF team names and the conferences and divisions they belong to
#'
#' @docType data
#' @format A data frame with 130 rows and 4 variables containing NCAAF team level
#' information:
#' \describe{
#'   \item{team}{Team name}
#'   \item{conf}{Conference abbreviation}
#'   \item{division}{Division name}
#'   \item{sdiv}{Division abbreviation}
#' }
#' This data frame is created using the `cfbd_team_info` function and the
#' `cfbd_conf_types_df` data frame of the `cfbfastR` package.
#' Please see `data-raw/divisions.R` for the code to create this data.
#'
#' @examples
#' \donttest{
#' divisions
#' }
"divisions"
