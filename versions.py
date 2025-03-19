versions = {
    "1.12.1": {"python": [7, 8, 9, 10], "cuda": [113, 116], "CXX": [False, False]},
    "1.13.1": {"python": [7, 8, 9, 10], "cuda": [113, 117], "CXX": [False, False]},
    "2.0.1": {"python": [8, 9, 10, 11], "cuda": [117, 118], "CXX": [False, False]},
    "2.1.2": {"python": [8, 9, 10, 11], "cuda": [118, 121], "CXX": [False, False]},
    "2.2.2": {"python": [8, 9, 10, 11], "cuda": [118, 121], "CXX": [False, False]},
    "2.3.1": {"python": [8, 9, 10, 11], "cuda": [118, 121], "CXX": [False, False]},
    "2.4.1": {"python": [8, 9, 10, 11], "cuda": [118, 121, 124], "CXX": [False, False, False]},
    "2.5.1": {"python": [9, 10, 11, 12], "cuda": [118, 121, 124], "CXX": [False, False, False]},
    "2.6.0": {"python": [9, 10, 11, 12], "cuda": [118, 124, 126], "CXX": [False, False, True]},
}

cuda_version_mapping = {
    113: "11.8.0",
    116: "11.8.0",
    117: "11.8.0",
    118: "11.8.0",
    121: "12.1.1",
    124: "12.4.0",
    126: "12.6.0",
}

pairs_set = set()
pairs = []
for torch_version, pycu in versions.items():
    for python_version in pycu["python"]:
        python_version = f"3.{python_version}"
        for cuda_version, cxx11abi in zip(pycu["cuda"], pycu["CXX"]):
            cuda_version = cuda_version_mapping[cuda_version]
            pair = (torch_version, python_version, cuda_version, str(cxx11abi).upper())
            if pair not in pairs_set:
                pairs.append(pair)
                pairs_set.add(pair)

for torch_version, python_version, cuda_version, cxx11abi in pairs:
    print(f"- torch-version: \"{torch_version}\"")
    print(f"  python-version: \"{python_version}\"")
    print(f"  cuda-version: \"{cuda_version}\"")
    print(f"  cxx11abi: {cxx11abi}")
