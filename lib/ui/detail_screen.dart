import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:themealdb/bloc/detail_bloc.dart';
import 'package:themealdb/model/item_model.dart';
import 'package:themealdb/resources/favorite_local_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailScreen extends StatefulWidget {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String type;

  const DetailScreen(
      {Key? key, required this.idMeal, required this.strMeal, required this.strMealThumb, required this.type})
      : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final bloc = DetailBloc();
  ItemModel? itemModel;
  bool _isFavorite = false;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );
  final BannerAd myBanner = BannerAd(
    adUnitId: kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : 'ca-app-pub-7540836345366849/5968563544',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  final AdSize adSize = AdSize(height: 60, width: 468);
  final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );

  YoutubePlayerController? ytController;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    bloc.fetchDetailMeals(widget.idMeal);
    FavoriteLocalProvider.db.getFavoriteMealsById(widget.idMeal).then((v) {
      bloc.detailMeals.first.then((value) {
        ytController = YoutubePlayerController(
          initialVideoId: YoutubePlayer.convertUrlToId(value.meals.first.strYoutube ?? '') ?? '',
          flags: const YoutubePlayerFlags(
            mute: false,
            autoPlay: true,
            disableDragSeek: false,
            loop: true,
            forceHD: true,
            enableCaption: true,
          ),
        )..addListener(ytListener);
        _videoMetaData = const YoutubeMetaData();
        _playerState = PlayerState.unknown;
        setState(() {
          _isFavorite = v != null;
          itemModel = value;
        });
      });
    });
    myBanner.load();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    bloc.dispose();
    ytController!.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    ytController!.pause();
    super.deactivate();
  }

  void ytListener() {
    if (_isPlayerReady && mounted && !ytController!.value.isFullScreen) {
      setState(() {
        _playerState = ytController!.value.playerState;
        _videoMetaData = ytController!.metadata;
      });
    }
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: kDebugMode ? 'ca-app-pub-3940256099942544/1033173712' : 'ca-app-pub-7540836345366849/1637887559',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < 5) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  Widget build(BuildContext context) {
    final AdWidget adWidget = AdWidget(ad: myBanner);
    return ytController != null ?
    YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
      },
      player: YoutubePlayer(
        controller: ytController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              ytController!.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          /*
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              log('Settings Tapped!');
            },
          ),
          */
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          //ytController.reload();
        },
      ),
      builder: (context, player) => Scaffold(
        appBar: AppBar(
          title: Text(
            widget.strMeal.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          centerTitle: true,
          actions: [actionSaveorDelete()],
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: player,
              ),
              Flexible(
                child: SingleChildScrollView(
                    child: detailMeals()
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
          alignment: Alignment.center,
          child: adWidget,
          width: MediaQuery.of(context).size.width,
          height: myBanner.size.height.toDouble(),
        ),
      ),
    ) :
    Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 250,
              floating: false,
              pinned: true,
              leading: IconButton(
                key: Key('back'),
                icon: Icon(Icons.arrow_back),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              actions: <Widget>[
                actionSaveorDelete()
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  widget.strMeal,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                background: Hero(
                  tag: widget.strMeal,
                  child: Image.network(widget.strMealThumb,width: double.infinity,
                      fit: BoxFit.cover),
                ),
              ),
            ),
          ];
        },
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget detailMeals() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(4.0),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Composition :",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      itemModel?.meals[0].strIngredients.join(', ') ?? '',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Instruction :",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      itemModel?.meals[0].strInstructions ?? '',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionSaveorDelete(){
  if (_isFavorite) {
      return GestureDetector(
        onTap: () {
          FavoriteLocalProvider.db.deleteFavoriteMealsById(widget.idMeal).then((value) {
            if (value > 0) {
              setState(() => _isFavorite = false);
            }
          });
          _showInterstitialAd();
         // showToast(context, "Remove from Favorite", duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Icon(Icons.favorite),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          Meals favoriteFood = Meals(
            idMeal: widget.idMeal,
            strMeal: widget.strMeal,
            strMealThumb: widget.strMealThumb,
            type: widget.type,
            strMeasures: [],
            strIngredients: []
          );
          FavoriteLocalProvider.db.addFavoriteMeals(favoriteFood).then((value) {
            if (value > 0) {
              setState(() => _isFavorite = true);
            }
          });
          _showInterstitialAd();
          //showToast(context, "Add to Favorite", duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Icon(Icons.favorite_border),
        ),
      );
    }
}
}

