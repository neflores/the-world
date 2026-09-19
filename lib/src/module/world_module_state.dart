/// Public lifecycle vocabulary; errors never replace a usable last snapshot.
enum WorldModuleState { loading, ready, stale, restricted, empty, error }
