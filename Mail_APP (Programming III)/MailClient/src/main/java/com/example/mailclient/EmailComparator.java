package com.example.mailclient;

import java.util.Comparator;

public class EmailComparator implements Comparator<Email> {
    @Override
    public int compare(Email o1, Email o2) {
        String giorno1 = String.valueOf(o1.getData().charAt(0)) + String.valueOf(o1.getData().charAt(1));
        String giorno2 = String.valueOf(o2.getData().charAt(0)) + String.valueOf(o2.getData().charAt(1));
        String mese1 = String.valueOf(o1.getData().charAt(3)) + String.valueOf(o1.getData().charAt(4));
        String mese2 = String.valueOf(o2.getData().charAt(3)) + String.valueOf(o2.getData().charAt(4));
        String anno1 = String.valueOf(o1.getData().charAt(6)) + String.valueOf(o1.getData().charAt(7));
        String anno2 = String.valueOf(o2.getData().charAt(6)) + String.valueOf(o2.getData().charAt(7));

        if(anno1.compareTo(anno2) == 0){
            if(mese1.compareTo(mese2) == 0){
                if(giorno1.compareTo(giorno2) == 0){
                    return o2.getOra().compareTo(o1.getOra());
                }else{
                    return giorno2.compareTo(giorno1);
                }
            }else{
                return mese2.compareTo(mese1);
            }
        }else{
            return anno2.compareTo(anno1);
        }
    }

    @Override
    public boolean equals(Object obj) {
        if(this == obj){
            return true;
        }else if(obj == null || getClass() != obj.getClass()){
            return false;
        }else{
            return true;
        }
    }
}
