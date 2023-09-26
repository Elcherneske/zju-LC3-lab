#include <iostream>
#include <fstream>
#include <sstream>
#include "Document.h"
#include "IndexGenerator.h"

#include<windows.h>

#define IS_DATA_EXISTED 1

using namespace std;

vector<Document> ReadArticle(ifstream& shakespear);

vector<Document> ReadExistedData(ifstream& titles);

const string text_dir = "..//..//..//text//";




LARGE_INTEGER nFreq;
LARGE_INTEGER nBeginTime;
LARGE_INTEGER nEndTime;



int main()
{
    double time = 0;
    double counts = 0;

    ifstream shakespear(text_dir + "text.txt");

#if IS_DATA_EXISTED
    ifstream titles(text_dir + "titles.txt");
#endif


    if (!shakespear)
        cout << "Failed to open the input file." << endl;
    else
    {

#if IS_DATA_EXISTED
        vector<Document> works = ReadExistedData(titles);
#else
        vector<Document> works = ReadArticle(shakespear);
#endif // IS_DATA_EXISTED


        for (int i = 0; i < works.size(); i++)
            cout << works[i].getTitle() << endl;
        IndexGenerator SearchEngine(works);
        string words;
        getline(cin, words);

        QueryPerformanceFrequency(&nFreq);
        QueryPerformanceCounter(&nBeginTime);//开始计时

        vector<Node::Index>* index_list;
        for (int loop = 0; loop < 1000; loop++) {
            index_list = SearchEngine.search(words);
        }
        //vector<Node::Index>* index_list = SearchEngine.search(words);

        QueryPerformanceCounter(&nEndTime);//停止计时
        time = (double)(nEndTime.QuadPart - nBeginTime.QuadPart) / (double)nFreq.QuadPart;//计算程序执行时间单位为s
        cout << "search执行时间：" << time * 1000 << "ms" << endl;


        for (int i = 0; i < index_list->size(); ++i)
        {
            //cout << (*index_list)[i] << endl;
            for (int j = 0; j < works.size(); j++) {
                if (works[j].getTitle() == (*index_list)[i].DocumentID) {
                   // cout << works[j].getText((*index_list)[i].position) << endl;
                }
            }
        }

    }
    // TO DO:
    // Seperate the text and then build the IndexGenerator
    // Use the interface of IndexGenerator to return search results
}










vector<Document> ReadArticle(ifstream& shakespear)
{
    auto isnumber = [](char ch)
    {
        if (ch == '0' || ch == '1' || ch == '2' || ch == '3' || ch == '4' || ch == '5' || ch == '6' || ch == '7' || ch == '8' || ch == '9')
            return 1;
        else
            return 0;
    };
    int position = 0;
    int position2 = 0;
    int t, i, j;
    string whole, mid, mid2;
    vector<string> article;
    vector<string> name;
    getline(shakespear, whole, '+');

    while (whole.find("THE END", position) != string::npos)
    {
        t = position;
        position = whole.find("THE END", position);
        position += sizeof("THE END");
        mid.assign(whole, t, position - t + 1);
        position2 = mid.find(".>>", position);
        mid.erase(0, position2 + 3);
        article.push_back(mid);
    }
    cout << article.size() << endl
        << "done";
    for (i = 0; i < article.size(); i++)
    {
        int start = article[i].find("by William Shakespeare");
        int number = article[i].substr(0, start).find_last_of("0123456789");
        istringstream out(article[i].substr(number + 1, start));

        getline(out, mid);
        while (mid.size() == 0)
        {
            getline(out, mid);
        }
        name.push_back(mid);
        article[i] = article[i].substr(start + 23);
    }

    ofstream output(text_dir + "titles.txt");

    vector<Document> works(article.size());
    for (int i = 0; i < article.size(); i++)
    {
        output << name[i] << endl;
        cout << name[i] << endl;
        works[i] = Document(name[i], article[i]);
        works[i].Out2File(text_dir);
    }
    output.close();
    return works;
}

vector<Document> ReadExistedData(ifstream& titles)
{
    string title;
    vector<Document> works;
    while (getline(titles, title))
    {
        ifstream article(text_dir + title + ".txt");
        works.push_back(Document(title, article));
    }
    return works;

}
