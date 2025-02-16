# 🎬 Авито Маркетплейс
Проект демонстрирует реализацию приложения для маркетплейса, выполненного с использованием MVVM-C + ViewState и Dependency Injection. Приложение содержит три основных экрана:
1. Экран поиска/выдачи товаров<br>
2. Экран детальной карточки товара<br>
3. Экран корзины покупок с возможностью поделиться выдачей<br>
## 🛠 Технический стек
- Swift
- UIKit
- MVVM-C + ViewState
- CoreData
- NSCache
- UserDefaults
- Structured Concurrency
- GCD
- URLSession
- Dependency Injection

## 1 экран — Поисковый, выдача

__1. Список товаров с постраничной загрузкой.__ <br>
Товары загружаются с поддержкой пагинации и отображаются в виде плитки (2 товара в одном ряду).<br>
__2. Ячейки с изображениями.__ <br>
Каждая ячейка содержит изображение товара, заголовок, описание, цену и кнопки для добавления в избранное или корзину.<br>
__3. Поиск по тексту.__ <br>
Реализован поиск по заголовку товара с хранением последних пяти поисковых запросов.<br>
__4. Фильтры на экране выдачи.__ <br>
Пользователь может применить фильтры по заголовку, диапазону цен и категории через Bottom Sheet.<br>
__5. Empty State.__ <br>
Если товары не найдены или произошла ошибка при загрузке, отображается специальное пустое состояние с возможностью повторного запроса.<br>

<p align="center">
  <img width="200" alt="Screenshot 2025-02-16 at 18 24 53" src="https://github.com/user-attachments/assets/8c3cdff2-1e65-46ed-94c3-b85d9cbdc8d2" />
  <img width="200" alt="Screenshot 2025-02-16 at 18 27 07" src="https://github.com/user-attachments/assets/501c70a9-0320-4a86-bb8a-acd76c0b6ff8" />
  <img width="200" alt="Screenshot 2025-02-16 at 18 28 01" src="https://github.com/user-attachments/assets/477221ac-72b3-4033-891c-4a7f53eb8a2f" />
  <img width="200" alt="Screenshot 2025-02-16 at 18 28 47" src="https://github.com/user-attachments/assets/6810c69c-b727-4f7d-81a4-513e24a3c820" />
</p>

## 2 экран — Карточка товара
__1. Детальная информация о товаре.__ <br>
Экран отображает изображение (с возможностью просмотра в виде галереи), заголовок, описание, цену и категорию товара.<br>
__2. Поддержка загрузки placeholder.__ <br>
При ошибке загрузки изображения отображается placeholder.<br>
__3. Функция "Поделиться".__ <br>
Пользователь может поделиться информацией о товаре через системные опции.<br>
__4. Состояние кнопки "Добавить в корзину".__ <br>
Если товар уже добавлен в корзину, кнопка изменяет свой вид (например, отображается как "Перейти в корзину").<br>
<p align="center">
  <img width="200" alt="Screenshot 2025-02-16 at 18 34 37" src="https://github.com/user-attachments/assets/535f9d3d-ffbc-4ecc-997c-1235426f1972" />
  <img width="200" alt="Screenshot 2025-02-16 at 18 35 02" src="https://github.com/user-attachments/assets/16904f58-e115-40ed-933a-86d6f1e5dafa" />
  <img width="200" alt="Screenshot 2025-02-16 at 18 35 30" src="https://github.com/user-attachments/assets/30cadf14-6c70-4050-ae11-42b6c25b6671" />
  <img width="200" alt="Screenshot 2025-02-16 at 18 36 00" src="https://github.com/user-attachments/assets/dc0a135b-9d67-4047-a12e-046f57069e39" />
</p>

## 3 экран — Список покупок — Кнопка «поделиться выдачей»
__1. Корзина покупок с персистентностью.__ <br>
Список товаров, добавленных на первом или втором экране, сохраняется между запусками приложения.<br>
__2. Редактирование корзины.__ <br>
Возможность изменять количество товара, удалять отдельные товары и очищать корзину.__
__3. Функция "Поделиться".__ <br>
Позволяет отправить сводку корзины через мессенджеры или сохранить в «Заметки».<br>
__4. Синхронизация состояния.__ <br>
Состояние корзины синхронизировано с карточками товаров и экраном выдачи.<br>
<p align="center">
  <img width="200" alt="Screenshot 2025-02-16 at 18 37 26" src="https://github.com/user-attachments/assets/16b4eecf-dbe4-4ea7-8850-3a06e05ec9a8" />
  <img width="200" alt="Screenshot 2025-02-16 at 18 37 51" src="https://github.com/user-attachments/assets/ad75b7c1-5abe-41ae-8d3d-aa9acfcc215c" />
  <img width="200" alt="Screenshot 2025-02-16 at 18 38 16" src="https://github.com/user-attachments/assets/66e9da7d-c106-476d-865c-90b5cc63c71f" />
  <img width="200" alt="Screenshot 2025-02-16 at 18 38 51" src="https://github.com/user-attachments/assets/3d671ffc-8a6c-47d0-b1a7-fa33094d8c7d" />

</p>

## Поиск
__1. Простой и расширенный поиск.__ <br>
На главном экране реализован UISearchBar для поиска по заголовку товара. Дополнительно доступен экран фильтрации с расширенными параметрами (категории, диапазон цен, заголовок).<br>
<p align="center">
  <img width="200" alt="Screenshot 2025-02-16 at 18 28 25" src="https://github.com/user-attachments/assets/936afa9a-1728-4c82-bfb9-eae89a377a95" />
  <img width="200" alt="Screenshot 2025-02-16 at 18 41 21" src="https://github.com/user-attachments/assets/7e7cd28b-b0c9-4a0d-93d4-01cf293e98fb" />
</p>

## Автор

Alisher Zinullayev, alishisnotonfire@gmail.com
