library;

// configs
export '../../config/firebase_options.dart';
export '../../config/getit_instance.dart';
export '../../config/responsive_font.dart';
export '../../config/theme_services.dart';

// extras
export 'package:dio/dio.dart';
export 'package:flutter_dotenv/flutter_dotenv.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:equatable/equatable.dart';
export 'package:flutter/material.dart';
export 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
export '../data_provider/api_response.dart';
export '../data_provider/dio_client.dart';

// routes
export 'package:go_router/go_router.dart';
export '../../config/routes/app_routes.dart';
export '../../config/routes/app_pages.dart';

// services
export '../../services/audio_services.dart';
export '../../services/auth_services.dart';
export '../../services/box_services.dart';
export '../../services/extension_services.dart';
export '../../services/notification_services.dart';

// utils
export '../../data/utils/app_constants.dart';
export '../../data/utils/dimens.dart';
export '../../data/utils/image_resources.dart';
export '../../data/utils/string.dart';
export '../../data/utils/utils.dart';

// models
export '../../data/data_models/common/album_model.dart';
export '../../data/data_models/common/artist_model.dart';
export '../../data/data_models/common/other_models.dart';
export '../../data/data_models/common/playlist_model.dart';
export '../../data/data_models/common/tracks_model.dart';
export '../../data/data_models/library_model.dart';
export '../../data/data_models/profile_model.dart';
export '../../data/data_models/search_model.dart';

// repos
export '../../data/repositories/auth_repo.dart';
export '../../data/repositories/home_repo.dart';
export '../../data/repositories/library_repo.dart';
export '../../data/repositories/music_group_repo.dart';
export '../../data/repositories/music_repo.dart';
export '../../data/repositories/search_repo.dart';

// widgets
export '../../presentation/widgets/base_widget.dart';
export '../../presentation/widgets/custom_scroll_physics.dart';
export '../../presentation/widgets/dotted_border.dart';
export '../../presentation/widgets/loading_widgets.dart';
export '../../presentation/widgets/my_alert_dialog.dart';
export '../../presentation/widgets/my_cached_image.dart';
export '../../presentation/widgets/my_text_field_widget.dart';
export '../../presentation/widgets/shimmer_widget.dart';
export '../../presentation/widgets/top_widgets.dart';
