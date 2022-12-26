#! /bin/bash
#--------------------------------------------needed variables-------------------------------------

#initialize a variable to check the validation of string inputs 
Regex=^[A-Za-z][A-Za-z0-9_]*$
separator=":"
newline="\n"


#------------------------------------------------Functions department----------------------------------------

function create_table(){ 
         read -p "Please enter table name :  " table_name
                if [ -f $HOME/Databases/$1/$table_name ];then 
                     echo "this table already exists ! "
                     return 0 
                else
                       if ! [[ $table_name =~ $Regex ]]; then
                                 echo "invalid name "    
                        else 
                        read -p " initialize number of fields  please : " FieldNum
                        counter=1
                        PrimaryKey=""
                      #  metadata=""
                        #loop through the number of fields to know the name, type and either if they were a primary key or not 
                        FirstLine=""
                        while [ $counter -le $FieldNum ]
                        do 
                        
                           read -p "Name of Column : " ColName
                           
                       #     echo "Type of Column $ColName  :  " 
                        #   type=""
                                        while true 
                                        do
                                                read -p "please choose the data type of $ColName
                                                1)str
                                                2)int
                                                " option 
                                                if [[ $option == 1 ]]; then 
                                                      type="str"
                                                      break 
                                                elif [[ $option == 2 ]]; then 
                                                      type="int"
                                                      break
                                                else
                                                echo "wrong choice, try again please "
                                                fi      
                                        done
#validate the either the column is going to be a primary key or not 

                               while [ "$PrimaryKey" == "" ]   # if primary key=""
                                    do
                                        echo -e "do you want to make this column as a primary key ?"

                                        select answer in "yes" "no"
                                        do
                                            case $answer in

                                            yes ) PrimaryKey="PK";break;;
                                            
                                            no ) PrimaryKey="no";break;;

                                            * ) echo "invalid answer" 
                                                    ;;
                                            esac
                                        done
                                    done
                                 
                                 if [[ $PrimaryKey == "no" ]]; then 
                                     PrimaryKey=""
                                 fi
#push the whole formed date into an array so you can print it later 
                                arr[$counter]=$ColName$separator$type$separator$PrimaryKey

                                if [[ $counter < $FieldNum ]]; then 
                                FirstLine=$FirstLine$ColName$separator
                                else 
                                FirstLine=$FirstLine$ColName$newline
                                fi 

                                PrimaryKey=""

                                counter=$((counter + 1))

                        done  
                fi                  
        fi
#create two table -> for meta data , and for the normal data , push the previous data to the first one 
        touch $table_name
        touch meta_$table_name
        chmod 777 $table_name
        chmod 777 meta_$table_name
        echo -e $FirstLine >> $table_name
         for i in ${arr[*]}
           do
                echo -e "$i" >> meta_$table_name                                
            done
         if [[ -f $table_name && -f meta_$table_name ]]; then 
         echo "Table has been created "
         else 
         echo "Error , invalid trial "
         fi     
     }

function DropTable(){ 
        read -p "enter the table name" t
       if [ -f $t ]; then 
       rm $t
       rm meta_$t
       echo "Table has been deleted "
       else 
       echo "This tables doesn't exist !"
       fi
}



 function InsertIntoTable(){ 
        read -p "What table do you want to connect to ? " targeted_table

        if [ -f $targeted_table ]; 
        then
                echo "you're in the second part now "
                        #this way you will count the number of fields from the first line where they are separated  with full colon 
                        #save the variable where you can use it later 
                         Field_num= awk -F ":" '{if(NR==1) print NF}' $targeted_table
                      #  echo "$Field_num"
                        counter=2
                        while ! [[ $counter == $Field_num ]]
                        do  
                        #iterate through every column to get these values 
                                FieldName=awk -F ":" '{ if(NR=='$i') print $1}' meta_$table_name
                                FieldType=awk -F ":" '{ if(NR=='$i') print $2}' meta_$table_name
                                FieldPrimaryKey=awk -F ":"'{ if(NR=='$i') print $3}' meta_$table_name

                                read -p "Enter field ( $FieldName ): " input
                                #check the previous three extracted info 

                                if [[ "$FieldType" == "int" ]]; then  
                                                        # if the data type of the field is int make sure to validate the input as an integer with the matching regex
                                                        while ! [[ "$input" =~ ^[1-9]*[1-9]+$|^[1-9]+[0-9]*$ ]]
                                                        do
                                                                echo -e "error! invalid Data type , please enter it correctly"
                                                                read input
                                                        done


                                # validate the input in case if it was a string 

                                elif [ "$FieldType" = "str" ]
                                                        then

                                                                
                                                        while ! [[ "$input" =~ ^[a-zA-Z]  ]]
                                                        do

                                                                echo -e "error! Invalid input , please try again "
                                                                read input
                                                        done
                                fi 

                                #check the validation of the primary key 
                                if [[ $FieldPrimaryKey == "PK" && $input != "PK" ]]; then 
                                echo "this must be a primary key "
                                Input ="PK"
                                fi 
                #if the last round consider starting  a new line , otherwise assign a separator so you can add more values to the record and then append it normally
                                if [[ $counter == $Field_num ]]; then 
                                record=$record$input$
                                else 
                                record=$record$input$separator
                                fi 
                                echo -e input  >> $targeted_table

                        counter=$((counter+1)) 
                        done 
        else
         echo " Error, $targeted_table doesn't exist !  "
        fi    

 }


 function Select_From_Table(){ 
          read -p "Enter table name please :- " table 
          if ! [[ -f $table ]]; then 
          echo "invalid, this table doesn't exist "
          return 0 
          fi 
        select choice in Select_all Select_row Exit
        do 
                case $choice in 
                "Select_all" )
                cat $table
                ;;
                
                "Select_row" )
                  read -p "please Enter the condition value " val
                   sed -n "/${val}/p" $table
                ;; 

                "Exit" )
                break
                ;;
                *)
                echo "Invalid choice, please try again"
                esac 

        done 


 }


function Delete_From_Table(){   
        read -p "could you please enter the table name ?  " table_name
        while ! [[ -f $table_name ]] 
        do  
                 read  -p "this table doesn't exist  please enter an existing table " table_name
        done 
        while true 
        do 
               read -p  "please select one of these options 
                        1)delete all the table
                        2)delete by row
                        3)exit
                        " option
                if [[ $option == 1 ]]; then 
                 sed -i '2,$d' $table_name
                elif [[ $option == 2 ]]; then 
                     read -p "Enter the condition value :" val
                     sed -i "/$val/d" $table_name

                elif [[ $option == 3 ]]; then 
                     break 
                 else 
                 echo "Invalid choice , please try again !"
                 fi 
        done 
}









function tables_menu() {
                    while true 
                        do 
                            read -p "
                                    please select an option
                                    1)- Create Table 
                                    2)- List Tables
                                    3)- Drop Table
                                    4)- Insert into Table
                                    5)- Select From Table
                                    6)- Delete From Table
                                    7)- Update Table 
                                    8)- Exit
                                    " option

                                    if [[ $option == 1 ]]; 
                                        then
                                       #cd $HOME/DBMSEngine
                                      create_table "$1"
                                        
                                    elif [[ $option == 2 ]]; 
                                        then  
                                        ls

                                    elif [[ $option == 3 ]]; 
                                        then 
                                        DropTable 

                                    elif [[ $option == 4 ]]; 
                                        then 
                                        InsertIntoTable

                                    elif [[ $option == 5 ]]; 
                                        then 
                                        Select_From_Table

                                    elif [[ $option == 6 ]]; 
                                        then 
                                        Delete_From_Table

                                    elif [[ $option == 7 ]]; 
                                        then 
                                        echo "Update Table"

                                    elif [[ $option == 8 ]]; 
                                        then 
                                        break

                                    else
                                    echo " Invalid, please try again with a valid option "

                                        fi 

                        done 
  }





#------------------------------------------------The Database menu-------------------------------------------------




#checking if the directory of the database is there , otherwise we create it , and check its permissions
  if [ ! -d $HOME/Databases ]; 
        then
        mkdir $HOME/Databases
        chmod 777 $HOME/Databases
  fi 

while true 
do 
                read -p " 
              please select an option
              1)- Create Database
              2)- List Databases
              3)- Connect To Databases
              4)- Drop Database
              5)-Exit
              " option
              if [[ $option == 1 ]]; 
              then   
                        read -p "Enter the Database name :  " DB_name
                        if [ -d $HOME/Databases/$DB_name ]; then
                                echo "there is an existing database with the same name "
                                #check the regex,then check if it's already exist, if both okay then create it otherwise don't

                        elif [[ $DB_name =~ $Regex ]]; then #this will check the statement if the string isn't valid will break it
                                mkdir $HOME/Databases/$DB_name
                                echo "Database has been created"
                        else 
                                "Invalid name ,  "
                        fi 

              elif [[ $option == 2 ]]; 
              then  
                      ls -F $HOME/Databases | grep /

              elif [[ $option == 3 ]]; 
              then 
                          #no need to check the regex, just check if it exists otherwise turn him down
                        read -p "which Database you want to be connected to ?" connect 
                        if [[ -d $HOME/Databases/$connect ]]; then  
                           cd $HOME/Databases/$connect
                           echo " you're in $connect database now "
                           tables_menu "$connect"
                        else 
                            echo "sorry, $conncet Database doesn't exist"
                       fi
              elif [[ $option == 4 ]]; 
              then   
                       #don't check the regex,you don't need to validate , just check the db dir and compare 
                        read -p "which Database you want to drop ?   " name 
                        if [[ -d $HOME/Databases/$name ]]; then  
                                rm -r $HOME/Databases/$name 
                                echo "Database has been dropped"
                        else 
                                echo "$connect database doesn't exist "
                        fi
              elif [[ $option == 5 ]]; 
              then 
                          break
              else 
                     echo "Invalid , please try again  "

              fi                                            
  done
