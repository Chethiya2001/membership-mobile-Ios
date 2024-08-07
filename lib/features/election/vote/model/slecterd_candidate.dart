class Candidate {
  final int id;
  final int positionId;
  final int electionId;
  final bool isSelected;

  Candidate({
    required this.id,
    required this.positionId,
    required this.electionId,
    this.isSelected = false,
  });
}
