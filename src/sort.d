import common;

// Merge Sort
// I referred below link.
// https://ja.wikipedia.org/wiki/%E3%83%9E%E3%83%BC%E3%82%B8%E3%82%BD%E3%83%BC%E3%83%88
public void Merge(ref MoveAndScore[][] A, ref MoveAndScore[][] B, int left, int mid, int right, int ply)
{
    int i = left;
    int j = mid;
    int k = 0;
    int l;
    while (i < mid && j < right)
    {
        if (A[ply][i].score <= A[ply][j].score)
        {
            B[ply][k++] = A[ply][i++];
        }
        else
        {
            B[ply][k++] = A[ply][j++];
        }
    }
    if (i == mid)
    {
        while (j < right)
        {
            B[ply][k++] = A[ply][j++];
        }
    }
    else
    {
        while (i < mid)
        {
            B[ply][k++] = A[ply][i++];
        }
    }
    for (l = 0; l < k; l++)
    {
        A[ply][left + l] = B[ply][l];
    }
}

public static void MergeSort(ref MoveAndScore[][] A, ref MoveAndScore[][] B, int left, int right, int ply)
{
    int mid;
    if (left == right || left == right - 1) { return; }
    mid = (left + right) / 2;
    MergeSort(A, B, left, mid, ply);
    MergeSort(A, B, mid, right, ply);
    Merge(A, B, left, mid, right, ply);
}

public void Merge(ref MoveAndProb[][] A, ref MoveAndProb[][] B, int left, int mid, int right, int ply)
{
    int i = left;
    int j = mid;
    int k = 0;
    int l;
    while (i < mid && j < right)
    {
        if (A[ply][i].trans_prob <= A[ply][j].trans_prob)
        {
            B[ply][k++] = A[ply][i++];
        }
        else
        {
            B[ply][k++] = A[ply][j++];
        }
    }
    if (i == mid)
    {
        while (j < right)
        {
            B[ply][k++] = A[ply][j++];
        }
    }
    else
    {
        while (i < mid)
        {
            B[ply][k++] = A[ply][i++];
        }
    }
    for (l = 0; l < k; l++)
    {
        A[ply][left + l] = B[ply][l];
    }
}

public void MergeSort(ref MoveAndProb[][] A, ref MoveAndProb[][] B, int left, int right, int ply)
{
    int mid;
    if (left == right || left == right - 1) { return; }
    mid = (left + right) / 2;
    MergeSort(A, B, left, mid, ply);
    MergeSort(A, B, mid, right, ply);
    Merge(A, B, left, mid, right, ply);
}
