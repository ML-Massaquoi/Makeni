import 'package:intl/intl.dart';

enum MysterySet { joyful, sorrowful, glorious, luminous }

class Mystery {
  final String name;
  final String virtue;
  final int number;

  const Mystery(this.number, this.name, this.virtue);
}

class RosaryStep {
  final String id;
  final String label;
  final String text;
  final String? subtitle;
  final bool isDecadeStart;
  final bool isMystery;
  final String? mysteryName;
  final int? hailMaryCount;

  const RosaryStep({
    required this.id,
    required this.label,
    required this.text,
    this.subtitle,
    this.isDecadeStart = false,
    this.isMystery = false,
    this.mysteryName,
    this.hailMaryCount,
  });
}

class RosaryService {
  static final _mysterySets = {
    MysterySet.joyful: [
      Mystery(1, 'The Annunciation of the Angel to Mary', 'Humility'),
      Mystery(2, "Mary's Visit to Her Cousin Elizabeth", 'Love of Neighbour'),
      Mystery(3, 'The Birth of Jesus in the stable of Bethlehem', 'Spirit of Poverty'),
      Mystery(4, 'The Presentation of Jesus in the Temple', 'Obedience to God'),
      Mystery(5, 'Jesus is found again among the Doctors in the Temple', 'Love the Bible'),
    ],
    MysterySet.sorrowful: [
      Mystery(1, 'Jesus Prays at Gethsemane', 'Spirit of Prayer'),
      Mystery(2, 'Jesus is Scourged at the Pillar', 'Modesty'),
      Mystery(3, 'Jesus is Crowned with Thorns', 'Purity of mind and Heart'),
      Mystery(4, 'Jesus Carries the Cross to Calvary', 'Patience in Suffering'),
      Mystery(5, 'Jesus Dies for Our Sins', 'Love for the Mass'),
    ],
    MysterySet.glorious: [
      Mystery(1, 'Jesus Rises from the Dead', 'Faith'),
      Mystery(2, 'Jesus Ascends into Heaven', 'Desire of Heaven'),
      Mystery(3, 'The Holy Spirit Descends on the Apostles', 'Wisdom, Fortitude'),
      Mystery(4, 'The Mother of Jesus is Assumed into Heaven', 'Holy Life, Holy Death'),
      Mystery(5, 'Mary Is Crowned Queen of Heaven and Earth', 'Final Perseverance'),
    ],
    MysterySet.luminous: [
      Mystery(1, 'The Baptism of Jesus', 'Our Baptism. Born Again'),
      Mystery(2, 'The Wedding at Cana', 'Mortification'),
      Mystery(3, 'The Proclamation of Good News', 'Zeal and Courage'),
      Mystery(4, 'The Transfiguration', '"Lord it is good for us"'),
      Mystery(5, 'The Institution of the Eucharist', 'The Bread of Life'),
    ],
  };

  static MysterySet mysterySetForDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return MysterySet.joyful;
      case DateTime.tuesday:
        return MysterySet.sorrowful;
      case DateTime.wednesday:
        return MysterySet.glorious;
      case DateTime.thursday:
        return MysterySet.luminous;
      case DateTime.friday:
        return MysterySet.sorrowful;
      case DateTime.saturday:
        return MysterySet.joyful;
      case DateTime.sunday:
        return MysterySet.glorious;
      default:
        return MysterySet.joyful;
    }
  }

  static List<Mystery> mysteriesForDay(DateTime date) {
    return _mysterySets[mysterySetForDay(date)]!;
  }

  static String mysterySetTitle(MysterySet set) {
    switch (set) {
      case MysterySet.joyful:
        return 'The Joyful Mysteries';
      case MysterySet.sorrowful:
        return 'The Sorrowful Mysteries';
      case MysterySet.glorious:
        return 'The Glorious Mysteries';
      case MysterySet.luminous:
        return 'The Luminous Mysteries';
    }
  }

  static String mysterySetDayLabel(DateTime date) {
    final dayName = DateFormat('EEEE').format(date);
    switch (mysterySetForDay(date)) {
      case MysterySet.joyful:
        return 'Mondays & Saturdays';
      case MysterySet.sorrowful:
        return 'Tuesdays & Fridays';
      case MysterySet.glorious:
        return 'Wednesdays & Sundays';
      case MysterySet.luminous:
        return 'Thursdays';
    }
  }

  static List<RosaryStep> buildSequence(List<Mystery> mysteries) {
    final steps = <RosaryStep>[];

    // Opening
    steps.addAll(_openingPrayers);
    steps.addAll(_introductoryPrayers);

    // Decades
    for (final mystery in mysteries) {
      steps.addAll(_decadePrayers(mystery));
    }

    // Closing
    steps.addAll(_closingPrayers);

    return steps;
  }

  static List<RosaryStep> get _openingPrayers => [
        const RosaryStep(
          id: 'sign_of_cross',
          label: 'Sign of the Cross',
          text: 'In the name of the Father,\nand of the Son,\nand of the Holy Spirit.\n\nAmen.',
        ),
        const RosaryStep(
          id: 'apostles_creed',
          label: 'The Apostles\' Creed',
          text: 'I believe in God,\nthe Father almighty,\nCreator of heaven and earth,\nand in Jesus Christ, his only Son, our Lord,\nwho was conceived by the Holy Spirit,\nborn of the Virgin Mary,\nsuffered under Pontius Pilate,\nwas crucified, died and was buried;\nhe descended into hell;\non the third day he rose again from the dead;\nhe ascended into heaven,\nand is seated at the right hand of God the Father almighty;\nfrom there he will come to judge the living and the dead.\n\nI believe in the Holy Spirit,\nthe holy Catholic Church,\nthe communion of saints,\nthe forgiveness of sins,\nthe resurrection of the body,\nand life everlasting.\n\nAmen.',
        ),
      ];

  static List<RosaryStep> get _introductoryPrayers => [
        const RosaryStep(
          id: 'our_father_1',
          label: 'Our Father',
          text: 'Our Father, who art in heaven,\nhallowed be thy name;\nthy kingdom come;\nthy will be done\non earth as it is in heaven.\n\nGive us this day our daily bread;\nand forgive us our trespasses\nas we forgive those who trespass against us;\nand lead us not into temptation,\nbut deliver us from evil.\n\nAmen.',
        ),
        const RosaryStep(
          id: 'hail_mary_1',
          label: 'Hail Mary (1)',
          text: 'Hail Mary, full of grace,\nthe Lord is with thee;\nblessed art thou among women,\nand blessed is the fruit of thy womb, Jesus.\n\nHoly Mary, Mother of God,\npray for us sinners,\nnow and at the hour of our death.\n\nAmen.',
          hailMaryCount: 1,
        ),
        const RosaryStep(
          id: 'hail_mary_2',
          label: 'Hail Mary (2)',
          text: 'Hail Mary, full of grace,\nthe Lord is with thee;\nblessed art thou among women,\nand blessed is the fruit of thy womb, Jesus.\n\nHoly Mary, Mother of God,\npray for us sinners,\nnow and at the hour of our death.\n\nAmen.',
          hailMaryCount: 2,
        ),
        const RosaryStep(
          id: 'hail_mary_3',
          label: 'Hail Mary (3)',
          text: 'Hail Mary, full of grace,\nthe Lord is with thee;\nblessed art thou among women,\nand blessed is the fruit of thy womb, Jesus.\n\nHoly Mary, Mother of God,\npray for us sinners,\nnow and at the hour of our death.\n\nAmen.',
          hailMaryCount: 3,
        ),
        const RosaryStep(
          id: 'glory_be_1',
          label: 'Glory Be',
          text: 'Glory be to the Father,\nand to the Son,\nand to the Holy Spirit.\n\nAs it was in the beginning,\nis now, and ever shall be,\nworld without end.\n\nAmen.',
        ),
      ];

  static List<RosaryStep> _decadePrayers(Mystery mystery) => [
        RosaryStep(
          id: 'mystery_${mystery.number}',
          label: 'The ${_ordinal(mystery.number)} Mystery',
          text: 'The ${_ordinal(mystery.number)} ${mystery.name}.\n\n"${mystery.virtue}"',
          subtitle: mystery.virtue,
          isMystery: true,
          mysteryName: mystery.name,
        ),
        RosaryStep(
          id: 'our_father_decade_${mystery.number}',
          label: 'Our Father',
          text: 'Our Father, who art in heaven,\nhallowed be thy name;\nthy kingdom come;\nthy will be done\non earth as it is in heaven.\n\nGive us this day our daily bread;\nand forgive us our trespasses\nas we forgive those who trespass against us;\nand lead us not into temptation,\nbut deliver us from evil.\n\nAmen.',
          isDecadeStart: true,
        ),
        // 10 Hail Marys
        for (int i = 1; i <= 10; i++)
          RosaryStep(
            id: 'hail_mary_decade_${mystery.number}_$i',
            label: 'Hail Mary ($i)',
            text: 'Hail Mary, full of grace,\nthe Lord is with thee;\nblessed art thou among women,\nand blessed is the fruit of thy womb, Jesus.\n\nHoly Mary, Mother of God,\npray for us sinners,\nnow and at the hour of our death.\n\nAmen.',
            hailMaryCount: i,
          ),
        const RosaryStep(
          id: 'glory_be_decade',
          label: 'Glory Be',
          text: 'Glory be to the Father,\nand to the Son,\nand to the Holy Spirit.\n\nAs it was in the beginning,\nis now, and ever shall be,\nworld without end.\n\nAmen.',
        ),
        RosaryStep(
          id: 'fatima_prayer_${mystery.number}',
          label: 'Fatima Prayer',
          text: 'O my Jesus,\nforgive us our sins,\npreserve us from the fire of Hell,\nand bring all souls to Heaven,\nespecially those who most need your mercy.\n\nAmen.',
        ),
      ];

  static List<RosaryStep> get _closingPrayers => [
        const RosaryStep(
          id: 'hail_holy_queen',
          label: 'Hail, Holy Queen',
          text: 'Hail, holy Queen, mother of mercy;\nhail, our life, our sweetness, and our hope!\nTo thee do we cry, poor banished children of Eve;\nto thee do we send up our sighs,\nmourning and weeping in this valley of tears.\n\nTurn, then, most gracious advocate,\nthine eyes of mercy toward us;\nand after this, our exile,\nshow unto us the blessed fruit of thy womb, Jesus.\n\nO clement, O loving, O sweet Virgin Mary.\n\nPray for us, O holy Mother of God,\nthat we may be made worthy of the promises of Christ.\n\nAmen.',
        ),
        const RosaryStep(
          id: 'sign_of_cross_end',
          label: 'Sign of the Cross',
          text: 'In the name of the Father,\nand of the Son,\nand of the Holy Spirit.\n\nAmen.',
        ),
      ];

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  int totalSteps() {
    // Opening (2) + introductory (5) + 5 decades * (announce + 1 + 10 + 1 + 1) + closing (2)
    return 2 + 5 + 5 * 14 + 2;
  }
}
