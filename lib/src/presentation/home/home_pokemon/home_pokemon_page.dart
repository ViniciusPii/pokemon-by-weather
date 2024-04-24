import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokemon_by_weather/src/core/theme/app_styles.dart';
import 'package:pokemon_by_weather/src/core/theme/infra/app_dimension.dart';
import 'package:pokemon_by_weather/src/core/ui/base_bloc_state.dart';
import 'package:pokemon_by_weather/src/core/ui/components/app_label.dart';
import 'package:pokemon_by_weather/src/core/ui/components/app_title.dart';
import 'package:pokemon_by_weather/src/core/ui/components/snack_bar/snack_bar_component.dart';
import 'package:pokemon_by_weather/src/core/ui/components/spacing_page.dart';
import 'package:pokemon_by_weather/src/core/ui/components/three_bounce_component.dart';
import 'package:pokemon_by_weather/src/domain/entities/weather_entity.dart';
import 'package:pokemon_by_weather/src/presentation/helpers/weather/weather_helpers.dart';
import 'package:pokemon_by_weather/src/presentation/home/home_pokemon/controller/home_pokemon_cubit.dart';
import 'package:pokemon_by_weather/src/presentation/home/home_pokemon/controller/home_pokemon_state.dart';
import 'package:pokemon_by_weather/src/presentation/widgets/card_pokemon_widget.dart';
import 'package:pokemon_by_weather/src/presentation/widgets/full_card_pokemon_widget.dart';
import 'package:pokemon_by_weather/src/routes/app_routes.dart';
import 'package:validatorless/validatorless.dart';

class HomePokemonPage extends StatefulWidget {
  const HomePokemonPage({super.key});

  @override
  State<HomePokemonPage> createState() => _HomePokemonPageState();
}

class _HomePokemonPageState extends BaseBlocState<HomePokemonPage, HomePokemonCubit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cityEC = TextEditingController();

  @override
  void dispose() {
    _cityEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SpacingPage(
          child: Column(
            children: [
              _BuildHeader(
                cityEC: _cityEC,
                controller: controller,
                formKey: _formKey,
              ),
              BlocConsumer<HomePokemonCubit, HomePokemonState>(
                bloc: controller,
                listener: (context, state) {
                  if (state is HomePokemonWeatherErrorState) {
                    return SnackBarComponent.error(context, message: state.message);
                  }

                  if (state is HomePokemonErrorState) {
                    return SnackBarComponent.error(context, message: state.message);
                  }

                  if (state is HomePokemonWeatherNetworkErrorState) {
                    return SnackBarComponent.info(context, message: state.message);
                  }
                },
                builder: (context, state) {
                  if (state is HomePokemonLoadingState) {
                    return const Expanded(
                      child: Center(
                        child: ThreeBounceComponent(),
                      ),
                    );
                  }

                  if (state is HomePokemonSuccessState) {
                    final WeatherEntity weather = state.weather;

                    return Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: AppDimension.extraLarge,
                            ),
                            AppTitle(
                              title:
                                  'Legal caçador! Você quer caçar em ${weather.city}, por aqui ${weather.conditionDisplay}, e a temperatura está ${weather.temp}º',
                            ),
                            const SizedBox(
                              height: AppDimension.mega,
                            ),
                            FullCardPokemonWidget(
                              type: state.type,
                              pokemon: state.pokemonToCatch,
                            ),
                            const SizedBox(
                              height: AppDimension.jumbo,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CardPokemonWidget(
                                  type: state.type,
                                  pokemon: state.pokemonsRunningAway.first,
                                ),
                                const SizedBox(
                                  width: AppDimension.extraLarge,
                                ),
                                const Icon(
                                  Icons.compare_arrows_outlined,
                                  size: AppDimension.big,
                                  color: AppStyles.textColor,
                                ),
                                const SizedBox(
                                  width: AppDimension.extraLarge,
                                ),
                                CardPokemonWidget(
                                  type: state.type,
                                  pokemon: state.pokemonsRunningAway.last,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: AppDimension.extraLarge,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.pokemonList,
                                arguments: state.type,
                              ),
                              child: const Text('Conheça todos pokemons'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const _BuildInitPage();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildInitPage extends StatelessWidget {
  const _BuildInitPage();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.74,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimension.extraLarge),
                  AppTitle(title: 'Está pronto para capturar?!'),
                  SizedBox(height: AppDimension.medium),
                  AppLabel(
                    label:
                        'Procure uma cidade e descubra qual pokemon pode te surpreender! Spoiler!!! As coisas podem mudar por aqui dependendo do clima! Boa Sorte!',
                    isCenter: false,
                  ),
                  SizedBox(height: AppDimension.medium),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimension.jumbo),
                child: Image.asset(
                  'assets/ash.png',
                  height: 350,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader({
    required this.cityEC,
    required this.formKey,
    required this.controller,
  });

  final HomePokemonCubit controller;
  final GlobalKey<FormState> formKey;
  final TextEditingController cityEC;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: AppDimension.large,
        ),
        Image.asset(
          'assets/pokemon_logo.png',
          height: 80,
        ),
        const SizedBox(
          height: AppDimension.extraLarge,
        ),
        Form(
          key: formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TextFormField(
                  controller: cityEC,
                  validator: Validatorless.multiple(
                    [
                      Validatorless.required('Campo obrigatório'),
                      Validatorless.regex(
                        RegExp(r'^[A-Za-záàâãéèêẽíìîĩóòôõúùûũüçÇs\s]+$'),
                        'Apenas caracteres!',
                      )
                    ],
                  ),
                  decoration: InputDecoration(
                    labelText: 'Digite a cidade que deseja caçar!',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        style: BorderStyle.none,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: AppDimension.medium,
              ),
              SizedBox(
                width: 50,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();

                    if (formKey.currentState!.validate()) {
                      controller.getWeatherByCity(cityEC.text);
                    }
                  },
                  child: const Icon(Icons.search),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
