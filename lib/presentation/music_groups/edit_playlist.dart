import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/buisness_logic/root_bloc/edit_playlist_bloc.dart';
import 'package:ampify/data/utils/exports.dart';

class EditPlaylistScreen extends StatefulWidget {
  final String id;
  final String? title;
  final String? image;
  final String? desc;
  const EditPlaylistScreen(
      {super.key,
      required this.id,
      required this.title,
      required this.image,
      required this.desc});

  @override
  State<EditPlaylistScreen> createState() => _EditPlaylistScreenState();
}

class _EditPlaylistScreenState extends State<EditPlaylistScreen> {
  @override
  void initState() {
    final bloc = context.read<EditPlaylistBloc>();
    bloc.add(EditPlaylistInitial(
      id: widget.id,
      title: widget.title,
      image: widget.image,
      desc: widget.desc,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final width = context.width * .6;
    final bloc = context.read<EditPlaylistBloc>();
    return BaseWidget(
      appBar: AppBar(backgroundColor: scheme.background),
      bodyPadding: Utils.insetsHoriz(Dimens.sizeExtraLarge),
      child: BlocBuilder<EditPlaylistBloc, EditPlaylistState>(
        buildWhen: (pr, cr) => pr.id != cr.id,
        builder: (context, state) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: Dimens.sizeSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyCachedImage(state.image,
                      height: width,
                      width: width,
                      borderRadius: Dimens.sizeExtraSmall),
                ],
              ),
              const SizedBox(height: Dimens.sizeExtraLarge),
              TextFormField(
                decoration: InputDecoration(
                  label: Text('Title'),
                  labelStyle: TextStyle(fontSize: Dimens.fontXXXLarge),
                ),
                style: TextStyle(fontSize: Dimens.fontXXXLarge),
                controller: bloc.titleContr,
              ),
              const SizedBox(height: Dimens.sizeMidLarge),
              TextFormField(
                decoration: InputDecoration(
                  label: Text('Describe your vibe!'),
                  labelStyle: TextStyle(fontSize: Dimens.fontXXXLarge),
                  constraints: BoxConstraints(maxHeight: 100),
                ),
                style: TextStyle(fontSize: Dimens.fontXXXLarge),
                controller: bloc.descContr,
                expands: true,
                maxLines: null,
              ),
              const SizedBox(height: Dimens.sizeSmall),
              Text(
                StringRes.playlistDesc,
                style: TextStyle(
                    color: scheme.textColorLight,
                    fontWeight: FontWeight.w500,
                    fontSize: Dimens.fontDefault),
              ),
              BlocListener<EditPlaylistBloc, EditPlaylistState>(
                  listener: (context, state) {
                    if (state.success) {
                      context.read<LibraryBloc>().add(LibraryRefresh());
                      context.goNamed(AppRoutes.libraryView);
                    }
                  },
                  child: SizedBox(height: context.height * .1)),
              BlocBuilder<EditPlaylistBloc, EditPlaylistState>(
                  buildWhen: (pr, cr) => pr.loading != cr.loading,
                  builder: (context, state) {
                    return LoadingButton(
                      isLoading: state.loading,
                      width: double.infinity,
                      onPressed: bloc.onEdited,
                      child: const Text(StringRes.submit),
                    );
                  })
            ],
          );
        },
      ),
    );
  }
}
