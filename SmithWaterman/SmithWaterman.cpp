#include "SmithWaterman.h"
#include <vector>
node::node(){
    data = 0;
    row = 0;
    col = 0;
}
node::node(bool s, int r, int c){
    data = 0;
    same = s;
    row = r;
    col = c;
}
bool node::get_same(){
    return same;
}
int node::how_many_parent(){
    return int(parent.size());
}
node* node::get_parent(int index){
    if(how_many_parent()) return parent[index];
    else return 0;
}

int max(int a, int b, int c){
    int now = 0;
    int target = 0;
    if(a > now){
        now = a;
        target = 1;
    }
    if(b > now){
        now = b;
        target = 2;
    }
    if(c > now){
        now = c;
        target = 3;
    }
    return target;
}

void node::write_data(node*& left, node*& up, node*& left_up){
    int a = left->get_data() - penalty;
    int b = up->get_data() - penalty;
    int c = left_up->get_data();
    
    if(get_same()) c += s_same;
    else c += s_diff;
    
    int result = max(a,b,c);
    
    switch (result){
        case 0:
            data = 0;
            break;
        case 1:
            data = a;
            parent.push_back(left);
            if(b == a) parent.push_back(up);
            if(c == a) parent.push_back(left_up);
            break;
        case 2:
            data = b;
            parent.push_back(up);
            if(c == b) parent.push_back(left_up);
            break;
        case 3:
            data = c;
            parent.push_back(left_up);
            break;
    }

}

void search(node*& root, node*& now, vector<int>& path, vector<char>& A, vector<char>& B, int& count){
    // debugger
    //=====================================================================//
                            bool DEBUGGER = false;
    //=====================================================================//
    
    // if reach leaf
    if(!(now->how_many_parent())){
        if(DEBUGGER){
            cout << "this node's is the end of similar sequence " << endl;
            cout << "path is ";
            for(int i = 0; i < path.size(); i++){
                cout << path[i] << " ";
            }
            cout << endl;
        }
        
        path_print(root, path, A, B, count);
        path.pop_back();
        return;
    }
    // if not leaf
    for(int i = 0; i < now->how_many_parent(); i++){
        node* next = now->get_parent(i);
        if(now->get_row() == next->get_row() && now->get_col() != next->get_col()) path.push_back(1);
        if(now->get_row() != next->get_row() && now->get_col() == next->get_col()) path.push_back(2);
        if(now->get_row() != next->get_row() && now->get_col() != next->get_col()) path.push_back(3);
        
        if(DEBUGGER) cout << "this node's data is " << now->get_data() << " keep searching" << endl;
        
        search(root, next, path, A, B, count);
    }
    path.pop_back();   
}

void path_print(node*& root, vector<int>& path, vector<char>& A, vector<char>& B, int& count){
    int row = root->get_row();
    int col = root->get_col();
    vector<char> seg_A;
    vector<char> seg_B;

    for(vector<int>::iterator i = path.begin(); i != path.end(); i++){
        switch(*i){
            case 1:
                seg_A.push_back(A[col-1]);
                seg_B.push_back('_');
                col--;
                break;
            case 2:
                seg_A.push_back('_');
                seg_B.push_back(B[row-1]);
                row--;
                break;
            case 3:
                seg_A.push_back(A[col-1]);
                seg_B.push_back(B[row-1]);
                col--;
                row--;
                break;
        }
    }
    
    // print each result
    reverse(seg_A.begin(), seg_A.end());
    reverse(seg_B.begin(), seg_B.end());
    
    cout << endl;
    for(int i = 0; i < seg_A.size(); i++){
        cout << seg_A[i];
    }
    
    cout << endl;
    
    for(int i = 0; i < seg_A.size(); i++){
        if(seg_A[i] == seg_B[i]) cout << "*";
        else if(seg_A[i] != seg_B[i] && seg_A[i] == '_') cout << " ";
        else if(seg_A[i] != seg_B[i] && seg_B[i] == '_') cout << " ";
        else cout << "|";
    }
    
    cout << endl;
    
    for(int i = 0; i < seg_B.size(); i++){
        cout << seg_B[i];
    }
    
    cout << endl;
    count++;
}