/// status : true
/// message : "Data retrieved successfully"
/// modes : {"Happy":[35939,17014,29865,36355,29970],"Angry":[29966,36732,33682,32421,23189,24545],"Bored":[1543,24139,29853,30492,30299,18015],"Disappointed":[24540,3964,7360,33451,30696,6337],"Embarassed":[23574,31408,21567,34333,29935,23014],"Hungry":[2930,17423,1087,7803,29625,22999],"Lonely":[5722,23433,17510,34152,28838,32164],"Hurt":[31412,31777,10003,17835,28702,23483],"Nervous":[12675,33980,31971,23512,20344,29933],"Proud":[32503,8979,19566,28836,22380,17704],"Relaxed":[30999,30675,17834,22406,33085,9522],"Scared":[9193,22792,17463,28356,32316,37729],"Surprised":[15849,36213,16078,17966,4767,31409],"Upset":[13796,20381,28697,22996,33453,27779],"Worried":[9471,3251,35861,24702,32504,34296],"Sick":[31011,28464,33538,34366,5749,18803],"Silly":[2077,5466,24455,23431,33444,3817],"Stressed":[16435,5490,31184,28698,30671,7370],"Excited":[6222,24586,34331,29013,5492,34334],"Tired":[5772,13538,23329,33653,6099,23413]}

class MoodsModel {
  MoodsModel({
    this.status,
    this.message,
    this.modes,
  });

  MoodsModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    modes = json['modes'] != null ? Modes.fromJson(json['modes']) : null;
  }

  bool? status;
  String? message;
  Modes? modes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (modes != null) {
      map['modes'] = modes?.toJson();
    }
    return map;
  }
}

/// Happy : [35939,17014,29865,36355,29970]
/// Angry : [29966,36732,33682,32421,23189,24545]
/// Bored : [1543,24139,29853,30492,30299,18015]
/// Disappointed : [24540,3964,7360,33451,30696,6337]
/// Embarassed : [23574,31408,21567,34333,29935,23014]
/// Hungry : [2930,17423,1087,7803,29625,22999]
/// Lonely : [5722,23433,17510,34152,28838,32164]
/// Hurt : [31412,31777,10003,17835,28702,23483]
/// Nervous : [12675,33980,31971,23512,20344,29933]
/// Proud : [32503,8979,19566,28836,22380,17704]
/// Relaxed : [30999,30675,17834,22406,33085,9522]
/// Scared : [9193,22792,17463,28356,32316,37729]
/// Surprised : [15849,36213,16078,17966,4767,31409]
/// Upset : [13796,20381,28697,22996,33453,27779]
/// Worried : [9471,3251,35861,24702,32504,34296]
/// Sick : [31011,28464,33538,34366,5749,18803]
/// Silly : [2077,5466,24455,23431,33444,3817]
/// Stressed : [16435,5490,31184,28698,30671,7370]
/// Excited : [6222,24586,34331,29013,5492,34334]
/// Tired : [5772,13538,23329,33653,6099,23413]

class Modes {
  Modes({
    this.happy,
    this.angry,
    this.bored,
    this.disappointed,
    this.embarassed,
    this.hungry,
    this.lonely,
    this.hurt,
    this.nervous,
    this.proud,
    this.relaxed,
    this.scared,
    this.surprised,
    this.upset,
    this.worried,
    this.sick,
    this.silly,
    this.stressed,
    this.excited,
    this.tired,
  });

  Modes.fromJson(dynamic json) {
    happy = json['Happy'] != null ? json['Happy'].cast<int>() : [];
    angry = json['Angry'] != null ? json['Angry'].cast<int>() : [];
    bored = json['Bored'] != null ? json['Bored'].cast<int>() : [];
    disappointed =
        json['Disappointed'] != null ? json['Disappointed'].cast<int>() : [];
    embarassed =
        json['Embarassed'] != null ? json['Embarassed'].cast<int>() : [];
    hungry = json['Hungry'] != null ? json['Hungry'].cast<int>() : [];
    lonely = json['Lonely'] != null ? json['Lonely'].cast<int>() : [];
    hurt = json['Hurt'] != null ? json['Hurt'].cast<int>() : [];
    nervous = json['Nervous'] != null ? json['Nervous'].cast<int>() : [];
    proud = json['Proud'] != null ? json['Proud'].cast<int>() : [];
    relaxed = json['Relaxed'] != null ? json['Relaxed'].cast<int>() : [];
    scared = json['Scared'] != null ? json['Scared'].cast<int>() : [];
    surprised = json['Surprised'] != null ? json['Surprised'].cast<int>() : [];
    upset = json['Upset'] != null ? json['Upset'].cast<int>() : [];
    worried = json['Worried'] != null ? json['Worried'].cast<int>() : [];
    sick = json['Sick'] != null ? json['Sick'].cast<int>() : [];
    silly = json['Silly'] != null ? json['Silly'].cast<int>() : [];
    stressed = json['Stressed'] != null ? json['Stressed'].cast<int>() : [];
    excited = json['Excited'] != null ? json['Excited'].cast<int>() : [];
    tired = json['Tired'] != null ? json['Tired'].cast<int>() : [];
  }

  List<int>? happy;
  List<int>? angry;
  List<int>? bored;
  List<int>? disappointed;
  List<int>? embarassed;
  List<int>? hungry;
  List<int>? lonely;
  List<int>? hurt;
  List<int>? nervous;
  List<int>? proud;
  List<int>? relaxed;
  List<int>? scared;
  List<int>? surprised;
  List<int>? upset;
  List<int>? worried;
  List<int>? sick;
  List<int>? silly;
  List<int>? stressed;
  List<int>? excited;
  List<int>? tired;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Happy'] = happy;
    map['Angry'] = angry;
    map['Bored'] = bored;
    map['Disappointed'] = disappointed;
    map['Embarassed'] = embarassed;
    map['Hungry'] = hungry;
    map['Lonely'] = lonely;
    map['Hurt'] = hurt;
    map['Nervous'] = nervous;
    map['Proud'] = proud;
    map['Relaxed'] = relaxed;
    map['Scared'] = scared;
    map['Surprised'] = surprised;
    map['Upset'] = upset;
    map['Worried'] = worried;
    map['Sick'] = sick;
    map['Silly'] = silly;
    map['Stressed'] = stressed;
    map['Excited'] = excited;
    map['Tired'] = tired;
    return map;
  }
}
