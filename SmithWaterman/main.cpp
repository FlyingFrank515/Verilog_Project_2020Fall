#include <iostream>
#include <vector>
#include <iomanip>
#include <algorithm>
#include "SmithWaterman.h"
using namespace std;

int main()
{
    string raw_A, raw_B;
    vector<char> A, B;
    cout << "please input sequence A: ";
    getline(cin,raw_A);
    for(int i = 0; i < raw_A.length(); i++){
        char a = char(raw_A[i]);
        if(a == 'A' || a == 'T' || a == 'C' || a == 'G'){
            A.push_back(a);
        }
        else{
            cout << "wrong input format!!" << endl;
            return 0;
        }
    }

    cout << "please input sequence B: ";
    getline(cin,raw_B);
    for(int i = 0; i < raw_B.length(); i++){
        char a = char(raw_B[i]);
         if(a == 'A' || a == 'T' || a == 'C' || a == 'G'){
            B.push_back(a);
        }
        else{
            cout << "wrong input format!!" << endl;
            return 0;
        }
    }
    
    // cout << A.size() << endl;
    // cout << B.size() << endl;
    // for(int i=0; i<A.size(); i++) cout << A[i]; 
    // cout << endl;
    // for(int i=0; i<B.size(); i++) cout << B[i]; 
    // cout << endl;

    vector< vector<node*> > matrix;
    
    // initialization
    for(int i = 0; i < (B.size()+1); i++){
        vector<node*> temp;
        if(i == 0){
            for(int j = 0; j < (A.size()+1); j++){
                node* n = new node(false, i, j);
                temp.push_back(n);
            }
        }
        else{
            node* n = new node(false, i ,0);
            temp.push_back(n);
        }
        matrix.push_back(temp);
    }
    
    // scoring the matrix and find the trace
    for(int i = 1; i < (B.size()+1); i++){
        for(int j = 1; j < (A.size()+1); j++){
            node* n = new node((A[j-1] == B[i-1]), i, j);
            n->write_data(matrix[i][j-1], matrix[i-1][j], matrix[i-1][j-1]);
            matrix[i].push_back(n);
        }
    }

    // print out the scoring matrix
    cout << "scoring matrix" << endl;
    for(int j = 0; j < (A.size()+1); j++){
        if(j == 0) cout << "     ";
        cout << A[j] << "  ";
    }
    cout << endl;
    for(int i = 0; i < (B.size()+1); i++){
        if(i != 0)cout << B[i-1] << " ";
        else cout << "  ";
        for(int j = 0; j < (A.size()+1); j++){
            cout << setw(2) << left << matrix[i][j]->get_data() << " ";
        }
        cout << endl;
    }

    // find the simlilar sequence 
    vector<node*> root;

    // go through the matrix and fill in the score
    vector<vector<node*>>::iterator itr_i;
    vector<node*>::iterator itr_j;
    int max = 0;
    for(itr_i = matrix.begin(); itr_i != matrix.end(); ++itr_i){
        for(itr_j = (*itr_i).begin(); itr_j != (*itr_i).end(); ++itr_j){
            if((*itr_j)->get_data() > max){
                max = (*itr_j)->get_data();
                root.clear();
                root.push_back(*itr_j);
            }
            else if((*itr_j)->get_data() == max) root.push_back(*itr_j);
        }
    }
    
    // traverse the path from the node with max score and print it out
    int count = 1;
    for(vector<node*>::iterator itr_root = root.begin(); itr_root != root.end(); ++itr_root){
        vector<int> path;
        search((*itr_root), (*itr_root), path, A, B, count);
    }
    cout << "there are total "<< count-1 << " results" << endl;
}
