# file: task_1/code/clean_absence.R
# 目的:
# - originalのRDSを読み込み
# - blank列削除、型整備
# - 不登校(list)を年付きで結合
# - 生徒数と左結合して不登校率を計算
# - cleanedへ保存

library(dplyr)
library(purrr)
library(readr)    # parse_number のため
library(janitor)  # clean_names のため
library(stringr)
library(tibble)

# パス（このスクリプト位置=task_1/code/ からの相対）
path_original <- "~/Desktop/ra-bootcamp-warmup/task_1/data/original"
path_cleaned <- "~/Desktop/ra-bootcamp-warmup/task_1/data/cleaned"

# ---------- 1) 読み込み ----------
students     <- readRDS(file.path(path_original, "students.rds"))
absence_list <- readRDS(file.path(path_original, "absence_list.rds"))
# class_list は今回は未使用だが、後工程向けに読み込みだけ
class_list   <- tryCatch(readRDS(file.path(path_original, "class_list.rds")),
                         error = function(e) NULL)

# ---------- 2) 列名を英語&スネークケースに統一（見やすさUP） ----------
# ここでは "都道府県/年度/生徒数/不登校者数" といった主要列がある前提。
# 日本語→英語のrenameは、実データに合わせて適宜調整してOK。
norm_students <- students %>%
  janitor::clean_names() %>%
  rename(
    prefecture = matches("都道府県|pref"),
    year       = matches("年度|year"),
    students_total = matches("生徒数|students")
  )
# absence_listはリスト内の各dfにclean_names()をかけて、最低限の列を揃える
absence_list_norm <- map(absence_list, ~ .x %>%
                           rename(
                             prefecture   = `都道府県`,
                             absence_total = `不登校生徒数`
                           )
)

# ---------- 3) blank列を削除（全部NAまたは空文字の列 & "blank" という名の列） ----------
drop_blank_cols <- function(df) {
  # 名前が "blank" の列は落とす
  df <- df %>% select(!matches("^blank$"))
  # 中身が全部NAか空文字の列を落とす
  df %>% select(where(~ !all(is.na(.x) | (is.character(.x) & str_trim(.x) == ""))))
}

norm_students <- drop_blank_cols(norm_students)
absence_list_norm <- map(absence_list_norm, drop_blank_cols)

# ---------- 4) 型の整備 ----------
# yearは整数に、生徒数・不登校数は数値に
# yearはlist結合時に .id から作る => まずabsence側を結合
absence_long <- bind_rows(absence_list_norm, .id = "year_raw")

# .id から年を数値化
# 例: "2013", "2013年度", "平成25" などを想定して parse_number() で数値抽出
# もし "平成/令和" の和暦表記しかなく西暦が取れない場合は、必要に応じて対応を追加。
absence_long <- absence_long %>%
  mutate(
    year = suppressWarnings(as.integer(parse_number(year_raw))),
    # prefecture文字列化
    prefecture = as.character(prefecture),
    # 数値列はできるだけ数値化（カンマ混じりもparse_numberで対応）
    absence_total = suppressWarnings(as.numeric(parse_number(as.character(absence_total))))
  ) %>%
  select(-year_raw)

# students 側も型をそろえる

norm_students <- norm_students %>%
  mutate(
    year = suppressWarnings(as.integer(parse_number(as.character(year)))),
    prefecture = as.character(prefecture),
    students_total = suppressWarnings(as.numeric(parse_number(as.character(students_total))))
  )

View(absence_long)
View(norm_students)

# ---------- 5) パネル化：生徒数(左) × 不登校(右) を prefecture & year で結合 ----------
panel <- norm_students %>%
  arrange(year, prefecture) %>%
  left_join(
    absence_long %>% select(prefecture, year, absence_total),
    by = c("prefecture", "year")
  )

# ---------- 6) 不登校率の計算（割合とパーセント） ----------
panel <- panel %>%
  mutate(
    absence_rate = if_else(!is.na(absence_total) & !is.na(students_total) & students_total > 0,
                           absence_total / students_total, NA_real_),
    absence_rate_pct = absence_rate * 100
  )

# ---------- 7) 仕上げ：列の並びを分かりやすく ----------
panel <- panel %>%
  relocate(year, prefecture, students_total, absence_total, absence_rate, absence_rate_pct)

# ---------- 8) 保存 ----------
# クリーニング済みの各データを保存
saveRDS(absence_long, file.path(path_cleaned, "absence_cleaned.rds"))
saveRDS(norm_students, file.path(path_cleaned, "students_cleaned.rds"))
saveRDS(panel,         file.path(path_cleaned, "panel_middle_school_absence.rds"))
