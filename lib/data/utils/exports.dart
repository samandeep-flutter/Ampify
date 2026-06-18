library;

// core
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:equatable/equatable.dart';
export 'package:flutter/cupertino.dart' hide RefreshCallback;
export 'package:flutter/services.dart';

// routes & configs
export 'package:go_router/go_router.dart';
export 'package:ampify/config/routes/app_routes.dart';
export 'package:ampify/config/routes/app_pages.dart';
export 'package:ampify/config/firebase_options.dart';
export 'package:ampify/config/getit_instance.dart';
export 'package:ampify/config/responsive_font.dart';
export 'package:ampify/config/theme_services.dart';

// utils
export 'package:ampify/data/utils/app_constants.dart';
export 'package:ampify/data/utils/dimens.dart';
export 'package:ampify/data/utils/image_resources.dart';
export 'package:ampify/data/utils/string.dart';
export 'package:ampify/data/utils/utils.dart';

// models
export 'package:ampify/data/data_models/common_models.dart';
export 'package:ampify/data/data_models/dashboard_model.dart';
export 'package:ampify/data/data_models/device_info_model.dart';
export 'package:ampify/data/data_models/firestore_models.dart';
export 'package:ampify/data/data_models/library_model.dart';
export 'package:ampify/data/data_models/track_model.dart';
export 'package:ampify/data/data_models/user_model.dart';

// widgets
export 'package:ampify/presentation/widgets/base_widget.dart';
export 'package:ampify/presentation/widgets/custom_scroll_physics.dart';
export 'package:ampify/presentation/widgets/dotted_border.dart';
export 'package:ampify/presentation/widgets/loading_widgets.dart';
export 'package:ampify/presentation/widgets/my_alert_dialog.dart';
export 'package:ampify/presentation/widgets/my_cached_image.dart';
export 'package:ampify/presentation/widgets/my_text_field_widget.dart';
export 'package:ampify/presentation/widgets/shimmer_widget.dart';
export 'package:ampify/presentation/widgets/top_widgets.dart';

// services
export 'package:ampify/services/audio_services.dart';
export 'package:ampify/services/auth_services.dart';
export 'package:ampify/services/box_services.dart';
export 'package:ampify/services/device_info.dart';
export 'package:ampify/services/extension_services.dart';
export 'package:ampify/services/notification_services.dart';

// extras
export 'package:dart_ytmusic_api/types.dart';
export 'package:dart_ytmusic_api/yt_music.dart';
export 'package:ampify/data/repositories/music_repo.dart';
export 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
export 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
export 'package:ampify/buisness_logic/player_bloc/player_slider_bloc.dart';
export 'package:ampify/buisness_logic/player_bloc/player_events.dart';
export 'package:ampify/buisness_logic/player_bloc/player_state.dart';
export 'package:ampify/presentation/track_widgets/track_tile.dart';
