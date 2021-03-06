#' Gather columns into key-value pairs.
#'
#' Gather takes multiple columns and collapses into key-value pairs,
#' duplicating all other columns as needed. You use \code{gather()} when
#' you notice that you have columns that are not variables.
#'
#' @param data A data frame.
#' @param key,value Names of key and value columns to create in output.
#' @param ... Specification of columns to gather. Use bare variable names.
#'   Select all variables between x and z with \code{x:z}, exclude y with
#'   \code{-y}. For more options, see the \link[dplyr]{select} documentation.
#' @inheritParams gather_
#' @seealso \code{\link{gather_}} for a version that uses regular evaluation
#'   and is suitable for programming with.
#' @export
#' @examples
#' library(dplyr)
#' # From http://stackoverflow.com/questions/1181060
#' stocks <- data.frame(
#'   time = as.Date('2009-01-01') + 0:9,
#'   X = rnorm(10, 0, 1),
#'   Y = rnorm(10, 0, 2),
#'   Z = rnorm(10, 0, 4)
#' )
#'
#' gather(stocks, stock, price, -time)
#' stocks %>% gather(stock, price, -time)
#'
#' # get first observation for each Species in iris data -- base R
#' mini_iris <- iris[c(1, 51, 101), ]
#' # gather Sepal.Length, Sepal.Width, Petal.Length, Petal.Width
#' gather(mini_iris, key = flower_att, value = measurement,
#'        Sepal.Length, Sepal.Width, Petal.Length, Petal.Width)
#' # same result but less verbose
#' gather(mini_iris, key = flower_att, value = measurement, -Species)
#'
#' # repeat iris example using dplyr and the pipe operator
#' library(dplyr)
#' mini_iris <-
#'   iris %>%
#'   group_by(Species) %>%
#'   slice(1)
#' mini_iris %>% gather(key = flower_att, value = measurement, -Species)
gather <- function(data, key, value, ..., na.rm = FALSE, convert = FALSE) {
  key_col <- col_name(substitute(key), "key")
  value_col <- col_name(substitute(value), "value")

  if (n_dots(...) == 0) {
    gather_cols <- setdiff(names(data), c(key_col, value_col))
  } else {
    gather_cols <- unname(dplyr::select_vars(names(data), ...))
  }


  gather_(data, key_col, value_col, gather_cols, na.rm = na.rm,
    convert = convert)
}

n_dots <- function(...) nargs()

#' Gather (standard-evaluation).
#'
#' This is a S3 generic.
#'
#' @param data A data frame
#' @param key_col,value_col Strings giving names of key and value columns to
#'   create.
#' @param gather_cols Character vector giving column names to be gathered into
#'   pair of key-value columns.
#' @param na.rm If \code{TRUE}, will remove rows from output where the
#'   value column in \code{NA}.
#' @param convert If \code{TRUE} will automatically run
#'   \code{\link{type.convert}} on the key column. This is useful if the column
#'   names are actually numeric, integer, or logical.
#' @keywords internal
#' @export
gather_ <- function(data, key_col, value_col, gather_cols, na.rm = FALSE,
                     convert = FALSE) {
  UseMethod("gather_")
}

#' @export
gather_.data.frame <- function(data, key_col, value_col, gather_cols,
                               na.rm = FALSE, convert = FALSE) {

  data2 <- reshape2::melt(data, measure.vars = gather_cols,
    variable.name = key_col, value.name = value_col, na.rm = na.rm)
  rownames(data2) <- NULL

  if (convert) {
    data2[[key_col]] <- type.convert(as.character(data2[[key_col]]),
      as.is = TRUE)
  }

  data2
}

#' @export
gather_.tbl_df <- function(data, key_col, value_col, gather_cols,
                           na.rm = FALSE, convert = FALSE) {
  dplyr::tbl_df(NextMethod())
}

#' @export
gather_.tbl_dt <- function(data, key_col, value_col, gather_cols,
                           na.rm = FALSE, convert = FALSE) {
  dplyr::tbl_dt(NextMethod())
}
