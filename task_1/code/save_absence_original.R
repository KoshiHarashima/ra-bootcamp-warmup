# library
library(readxl)
library(purrr)
library(dplyr)

# パス設定
path_raw <- "~/Desktop/ra-bootcamp-warmup/task_1/data/raw"
path_original <- "~/Desktop/ra-bootcamp-warmup/task_1/data/original"

# 1) 生徒数データの読み込み
students <- read_excel(file.path(path_raw, "生徒数/生徒数.xlsx"))

# 変数名を英語化（例）
students <- students %>%
  rename(prefecture = 都道府県, year = 年度, students_total = 生徒数)

# 保存
saveRDS(students, file.path(path_original, "students.rds"))

# 2) 不登校者数データの一括読み込み
absence_files <- list.files(
  path = file.path(path_raw, "不登校生徒数"),
  pattern = "\\.xlsx$",
  full.names = TRUE
)

absence_list <- map(absence_files, read_excel)

# 年ごとの名前を付ける（ファイル名から抽出）
names(absence_list) <- gsub("年度.*", "", basename(absence_files))

# 変数名を英語化（例）
absence_list <- map(absence_list, ~ rename(.x,
                                           prefecture = 都道府県,
                                           year = 年度,
                                           absence_total = 不登校者数))

# 保存
saveRDS(absence_list, file.path(path_original, "absence_list.rds"))

# 2) 学級数データの一括読み込み
class_files <- list.files(
  path = file.path(path_raw, "学級数"),
  pattern = "\\.xlsx$",
  full.names = TRUE
)

class_list <- map(class_files, read_excel)

# 年ごとの名前を付ける（ファイル名から抽出）
names(class_list) <- gsub("年度.*", "", basename(class_files))

# 変数名を英語化（例）
class_list <- map(class_list, ~ rename(.x,
                                           prefecture = 都道府県,
                                           year = 年度,
                                           absence_total = 不登校者数))

# 保存
saveRDS(class_list, file.path(path_original, "class_list.rds"))



