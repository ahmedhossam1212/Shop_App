import 'package:flutter/material.dart';
import 'package:shop_app/models/changefavorites_model.dart';
import 'package:shop_app/models/favorits_model.dart';
import 'package:shop_app/modules/categories.dart';
import 'package:shop_app/modules/favorites.dart';
import 'package:shop_app/modules/productes.dart';
import 'package:shop_app/modules/setting.dart';
import 'package:shop_app/shared/componantes/constans.dart';
import 'package:shop_app/shared/network/end_point.dart';
import 'package:shop_app/shared/network/local/dio_helper.dart';
import '../../models/categories_model.dart';
import '../../models/home_model.dart';
import '../../models/login_model.dart';
import 'states.dart';

class ShopCubit extends Cubit<ShopStates> {
  ShopCubit() : super(ShopInitialState());

  static ShopCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> bottomScreens = [
    const ProductsScreen(),
    const CategoriesScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  void changeBottomNav(int index) {
    currentIndex = index;
    emit(ShopChangeBottomNavState());
  }

  HomeModel? homeModel;
  Map<dynamic, dynamic> favorites = {};

  void getHomeData() {
    emit(ShopLoadingHomeDataState());

    DioHelper.getData(
      url: home,
      token: token,
    ).then((value) {
      homeModel = HomeModel.fromJson(value.data);
      //  print(homeModel!.status);
      // print(homeModel!.data!.banners[0].image);
      for (var element in homeModel!.data!.products) {
        favorites.addAll({
          element.id: element.inFavorites,
        });
      }
      debugPrint(favorites.toString());
      emit(ShopSuccessHomeDataState());
    }).catchError((error) {
      debugPrint(error.toString());
      emit(ShopErrorHomeDataState());
    });
  }

  CategoriesModel? categoriesModel;

  void getCategoriesData() {
    DioHelper.getData(
      url: getCategories,
    ).then((value) {
      categoriesModel = CategoriesModel.fromJson(value.data);
      emit(ShopSuccessCategoriesState());
    }).catchError((error) {
      debugPrint(error.toString());
      emit(ShopErrorCategoriesState());
    });
  }

  ChangeFavoritesModel? changeFavoritesModel;
  void changeFavorites(int? productId) {
    favorites[productId] = !favorites[productId];
    emit(ShopChangeFavoritesState());
    DioHelper.postData(
      url: Favorites,
      data: {
        'product_id': productId,
      },
      token: token,
    ).then((value) {
      changeFavoritesModel = ChangeFavoritesModel.fromJson(value.data);
      debugPrint(value.data);

      if (changeFavoritesModel!.status == false) {
        favorites[productId] = !favorites[productId];
      } else {
        getFavorites();
      }
      emit(ShopSuccessChangeFavoritesState(changeFavoritesModel!));
    }).catchError((error) {
      debugPrint(error.toString());
      favorites[productId] = !favorites[productId];
      emit(ShopErrorChangeFavoritesState());
    });
  }

  FavoritesModel? favoritesModel;
  void getFavorites() {
    emit(ShopLoadingGetFavoritesState());
    DioHelper.getData(
      url: Favorites,
      token: token,
    ).then((value) {
      favoritesModel = FavoritesModel.fromJson(value.data);
      debugPrint(value.data.toString());
      emit(ShopSuccessGetFavoritesState());
    }).catchError((error) {
      debugPrint(error.toString());
      emit(ShopErrorGetFavoritesState());
    });
  }

  ShopLoginModel? userData;
  void getUserData() {
    emit(ShopLoadingUserDataState());
    DioHelper.getData(
      url: PROFILE,
      token: token,
    ).then((value) {
      userData = ShopLoginModel.fromJson(value.data);
      debugPrint(value.data.toString());
      emit(ShopSuccessUserDataState(userData!));
    }).catchError((error) {
      debugPrint(error.toString());
      emit(ShopErrorUserDataState());
    });
  }

  void updateUserData({
    required String name,
    required String email,
    required String phone,
  }) {
    emit(ShopLoadingUpdateUserState());
    DioHelper.putData(
      url: UPDATE_PROFILE,
      token: token,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
      },
    ).then((value) {
      userData = ShopLoginModel.fromJson(value.data);
      // print(value.data.toString());
      emit(ShopSuccessUpdateUserState(userData!));
    }).catchError((error) {
      debugPrint(error.toString());
      emit(ShopErrorUpdateUserState());
    });
  }
}