#' Compute Pretty Simulations Summary Table
#'
#' @description Uses the R package gt to create a pretty html table of the
#'   cfbsimR simulation summary data frame.
#' @param object an object for which a summary is desired.
#' @param ... additional arguments passed on to the methods (currently not used).
#' @section Output of below example:
#' \if{html}{\figure{summary_tbl.png}{options: width=75\%}}
#' @examples
#' \donttest{
#' library(cfbsimR)
#' # set seed for recreation
#' set.seed(20220315)
#'
#' # Simulate the season 20 times in 1 round
#' sim <- cfbsimR::simulate_cfb(
#'   cfb_season = 2022,
#'   fresh_season = TRUE,
#'   simulations = 20
#' )
#'
#' # Create Summary Tables
#' tbl <- summary(sim)
#'
#' # The output of tbl is given in the above image.
#' }
#' @export
summary.cfbsimR_simulation <- function(object, ...){
  rlang::check_installed(c("gt", "scales"), "to compute a summary table.")

  title <- paste("simulating the", object$sim_params$cfb_season, "CFB season")
  subtitle <- paste("summary of", object$sim_params$simulations, "simulations using cfbsimR")

  data <- object$overall #%>%
    # mutate(
    #   division = gsub("AFC |NFC ", "", division),
    #   division = case_when(
    #     division == "East" ~ "E A S T",
    #     division == "North" ~ "N O R T H",
    #     division == "South" ~ "S O U T H",
    #     division == "West" ~ "W E S T",
    #     TRUE ~ NA_character_
    #   )
    # )

  afc <- data %>%
    filter(conf == "PAC") %>%
    select(team,wins,everything()) %>%
    select(-conf,-division) %>%
    arrange( desc(wins), desc(won_conf))

  names(afc) <- paste0("afc_", names(afc))

  # nfc <- data %>%
  #   filter(conf == "NFC") %>%
  #   select(-conf) %>%
  #   arrange(division, desc(wins), desc(won_conf))
  #
  # names(nfc) <- paste0("nfc_", names(nfc))

  tbl <- afc#bind_cols(afc, nfc)

  tbl %>%
    #group_by(afc_division) %>%
    gt::gt() %>%
    # see below
    table_theme() %>%
    gt::cols_label(
      afc_team = "",
     #nfc_team = "",

      afc_wins = gt::html("AVG.<br>WINS"),
      #nfc_wins = gt::html("AVG.<br>WINS"),

      afc_bowl = gt::html("Make<br>BOWL"),
      #nfc_playoff = gt::html("Make<br>POST"),

      afc_div1 = gt::html("Make<br>CONF"),
      #nfc_div1 = gt::html("Win<br>DIV"),

      afc_wins_ten = gt::html("10<br>Wins"),
      #nfc_seed1 = gt::html("No.1<br>Seed"),

      afc_won_conf = gt::html("Win<br>Conf"),
      #nfc_won_conf = gt::html("Win<br>Conf"),

      #afc_won_sb = gt::html("Win<br>SB"),
      #nfc_won_sb = gt::html("Win<br>SB"),

      #afc_draft1 = gt::html("No.1<br>Pick"),
      #nfc_draft1 = gt::html("No.1<br>Pick"),

      #afc_draft5 = gt::html("Top-5<br>Pick"),
      #nfc_draft5 = gt::html("Top-5<br>Pick"),
    ) %>%
    #gt::cols_hide(nfc_division) %>%
    gt::fmt_number(gt::ends_with("wins"), decimals = 1) %>%
    gt::fmt_percent(
      columns = c(
        gt::ends_with("bowl"),
        gt::ends_with("div1"),
        gt::ends_with("wins_ten"),
        gt::ends_with("won_conf"),
        gt::ends_with("won_sb"),
        gt::ends_with("draft1"),
        gt::ends_with("draft5")
      ),
      decimals = 0
    ) %>%
    gt::data_color(
      columns = c(
        gt::ends_with("bowl"),
        gt::ends_with("div1"),
        gt::ends_with("wins_ten"),
        gt::ends_with("won_conf"),
        gt::ends_with("won_sb")
      ),
      colors = scales::col_numeric(palette = table_colors_positive, domain = c(0, 1))
    ) %>%
    gt::data_color(
      columns = c(
        gt::ends_with("draft1"),
        gt::ends_with("draft5")
      ),
      colors = scales::col_numeric(palette = table_colors_negative, domain = c(0, 1))
    ) %>%
    cfbplotR::gt_cfb_fancy_school(afc_team) %>%
    # gt::text_transform(
    #   locations = gt::cells_body(gt::ends_with("team")),
    #   fn = function(x){
    #     url <- data.frame(team_abbr = x) %>%
    #       left_join(
    #         nflreadr::load_teams() %>%
    #           filter(!team_abbr %in% c("LAR", "OAK", "SD", "STL")) %>%
    #           select(team_abbr, team_logo_espn),
    #         by = "team_abbr"
    #       ) %>%
    #       pull(team_logo_espn)
    #     gt::web_image(url = url, height = 30)
    #   }) %>%
    gt::tab_source_note("cfbsimR") %>%
    gt::tab_spanner(
      label = gt::html(gt::web_image(
        "https://a.espncdn.com/i/teamlogos/ncaa_conf/500/9.png",
        height = 25
      )),
      columns = gt::starts_with("afc")
    ) %>%
    # gt::tab_spanner(
    #   label = gt::html(gt::web_image(
    #     "https://github.com/nflverse/nflfastR-data/raw/master/NFC.png",
    #     height = 25
    #   )),
    #   columns = gt::starts_with("nfc")
    # ) %>%
    # gt::tab_style(
    #   locations = list(gt::cells_body(nfc_team), gt::cells_column_labels(nfc_team)),
    #   style = gt::cell_borders("left", weight = gt::px(2))
    # ) %>%
    gt::tab_style(
      locations = gt::cells_body(columns = gt::ends_with("wins")),
      style = gt::cell_text(weight = "bold")
    ) %>%
    gt::tab_style(
      locations = gt::cells_source_notes(),
      style = gt::cell_text(
        align = "right",
        size = "large",
        font = list(
          gt::google_font("Audiowide"),
          gt::default_fonts()
        )
      )
    ) %>%
    gt::tab_style(
      locations = gt::cells_title(groups = "title"),
      style = gt::cell_text(
        weight = "bold",
        font = list(
          gt::google_font("Prosto One"),
          gt::default_fonts()
        ))
    ) %>%
    gt::tab_style(
      locations = gt::cells_title(groups = "subtitle"),
      style = gt::cell_text(
        weight = "normal",
        font = list(
          gt::google_font("Prosto One"),
          gt::default_fonts()
        ))
    ) %>%
    gt::tab_style(
      locations = gt::cells_row_groups(),
      style = list(
        gt::cell_text(align = "center", weight = "bold"),
        gt::cell_fill(color = "#F0F0F0")
      )
    ) %>%
    gt::tab_header(
      tools::toTitleCase(title),
      tools::toTitleCase(subtitle)
    )
}

# Taken from Thomas Mock's package gtExtras to avoid the dependency
# on a non cran package.
# https://github.com/jthomasmock/gtExtras/blob/HEAD/R/gt_theme_538.R
table_theme <- function(gt_object,...) {

  gt_object %>%
    gt::opt_all_caps()  %>%
    gt::opt_table_font(
      font = list(
        gt::google_font("Chivo"),
        gt::default_fonts()
      ),
      weight = 300
    ) %>%
    gt::tab_style(
      style = gt::cell_borders(
        sides = "top", color = "black", weight = gt::px(0)
      ),
      locations = gt::cells_column_labels(
        columns = gt::everything()
      )
    ) %>%
    gt::tab_style(
      style = gt::cell_borders(
        sides = "bottom", color = "black", weight = gt::px(1)
      ),
      locations = gt::cells_row_groups()
    ) %>%
    gt::tab_options(
      column_labels.background.color = "white",
      heading.border.bottom.style = "none",
      table.border.top.width = gt::px(3),
      table.border.top.style = "none", #transparent
      table.border.bottom.style = "none",
      column_labels.font.weight = "normal",
      column_labels.border.top.style = "none",
      column_labels.border.bottom.width = gt::px(2),
      column_labels.border.bottom.color = "black",
      row_group.border.top.style = "none",
      row_group.border.top.color = "black",
      row_group.border.bottom.width = gt::px(1),
      row_group.border.bottom.color = "white",
      stub.border.color = "white",
      stub.border.width = gt::px(0),
      data_row.padding = gt::px(3),
      source_notes.border.lr.style = "none",
      source_notes.background.color = "gray30",
      table.font.size = 16,
      heading.align = "center",
      heading.background.color = "gray30",
      ...
    )
}

# output of ggsci::rgb_material("light-blue") + "white"
table_colors_positive <- c("white",
                           "#E0F4FEFF", "#B2E5FCFF", "#80D3F9FF", "#4EC3F7FF", "#28B6F6FF", "#02A9F3FF",
                           "#029AE5FF", "#0187D1FF", "#0177BDFF", "#00579AFF"
)

# output of ggsci::rgb_material("orange") + "white"
table_colors_negative <- c("white",
                           "#FFF2DFFF", "#FFDFB2FF", "#FFCC7FFF", "#FFB74CFF", "#FFA626FF", "#FF9800FF",
                           "#FA8C00FF", "#F47B00FF", "#EE6C00FF", "#E55100FF"
)
