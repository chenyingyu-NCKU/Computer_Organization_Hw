#include <iostream>
#include <cstdlib>
#include <string>
#include <fstream>
#include <sstream>
#include <bitset>
#include <ctime>
#include <vector>
#include <iomanip>
using namespace std;

// input size: word(4 bytes), address: word (4 bytes) 
int main(int argc,char *argv[]){
	srand(time(NULL));
	
	string in_name = argv[1]; 
	string out_name = argv[2];
	//open file
	ifstream fileIn(in_name.c_str());
	ofstream fileOut(out_name.c_str());

	int cache_size,block_size,asso,replace;
	//save cachesize, blocksize, associative, replace data
	fileIn >> cache_size >> block_size >> asso >> replace;

    int block_num = cache_size / block_size; // words/ words
	int offset_width = 0;
	int index_width = 0;
	int temp1 = block_num;
	int temp2 = block_size * 4; // block size: word (4 bytes)

	while(temp1 /= 2){
        // if there're 16 blocks => index_width = 4 bits
        index_width++;
	}
	while(temp2 /= 2){ //offset len (bits)
        // if block_size = 4 bytes => offset_width = 2 bits
		offset_width++;
	}

	int tag_width = 32 - index_width - offset_width; //tag len = 32-4-2= 26
	
	int set_num, entry_num; //set_num => set num in cache; entry_num => entry num in a set
	switch(asso){
		case 0: // direct-mapped
			set_num = block_num;
			entry_num = 1;
			break;
		case 1: // four-way set
			set_num =  block_num / 4;
			entry_num = 4;
			index_width = index_width - 2; //because /4 => len-2
			tag_width = tag_width + 2; //index_len-2 => tag_len+2 (keep 32bits)
			break;
		case 2: // fully
			set_num = 1;
			entry_num = block_num;
            index_width = 0;
			tag_width = tag_width + index_width;
			break;
		default:
			break;
	}

	vector< vector<int> > valid(set_num, vector<int>(entry_num));
	vector< vector<unsigned int> > tag(set_num, vector<unsigned int>(entry_num));
	vector<int> FIFO_index(set_num);
	vector< vector<int> > LRU_index(set_num, vector<int>(entry_num));
	vector<int> LRU_max(set_num);
	
	for(int i = 0;i < set_num;i++){
		for(int j = 0;j < entry_num;j++){
			valid[i][j] = 0;
			tag[i][j] = 0;
			LRU_index[i][j] = -1;
		}
	}
	
    double access = 0;
    double miss = 0;
    unsigned int address;
	while(fileIn >> address){
        access++;
		
        // if there're 16 inedx_block(index_width = 4), 
        // each block can put 4 number(block_size = 4, offset_width = 2)
        // THUS, addr_index = 0~15 (16 index_block)
        //
        // EX: (45 words) 180: 10110100 (last two-bit won't matter, because offset_width = 2)
        // addr_index = 13, addr_tag = 2

        address *= 4; // word => bytes
		unsigned int addr_tag = address >> offset_width >> index_width;
		unsigned int addr_index = ((unsigned int)(address << tag_width)) >> tag_width >> offset_width;

        if(asso == 2) addr_index = 0; // or "segmentation fault"

        // output victim: 
		for(int i = 0;i < entry_num;i++){
            if(valid[addr_index][i] == 1 && tag[addr_index][i] == addr_tag){ //hit
				fileOut << -1 << endl;
				LRU_max[addr_index]++;
				LRU_index[addr_index][i] = LRU_max[addr_index];
				break;
			}else if(valid[addr_index][i] == 0){ //invlid + miss
				fileOut << -1 << endl;
				valid[addr_index][i] = 1;
				tag[addr_index][i] = addr_tag;
				LRU_max[addr_index]++;
				LRU_index[addr_index][i] = LRU_max[addr_index];
				FIFO_index[addr_index]++;
				FIFO_index[addr_index] = FIFO_index[addr_index] % entry_num;
                miss++;
				break;
			}else if(i == entry_num -1){ //miss + replace
                miss++;
				int rd = 0;
				if (entry_num == 1){ //directed-mapped replace
					rd = 0;
				}else if(replace == 0){ //FIFO replace
					FIFO_index[addr_index]++;
					FIFO_index[addr_index] = FIFO_index[addr_index] % entry_num;
					rd = FIFO_index[addr_index];
				}else if(replace == 1){ //LRU replace
					for(int j = 0;j < entry_num;j++){
						if(LRU_index[addr_index][j] < LRU_index[addr_index][rd]){
							rd = j;
						}
					}
					LRU_max[addr_index]++;
					LRU_index[addr_index][rd] = LRU_max[addr_index];
				}
				fileOut << tag[addr_index][rd] << endl;
				tag[addr_index][rd] = addr_tag;
			}
		}
	}
	
    fileOut << "Miss rate = " << setprecision(6) << fixed << miss/access << endl;
	//close file
	fileIn.close();
	fileOut.close();

	return 0;
}
