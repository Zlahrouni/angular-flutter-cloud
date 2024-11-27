import { Pipe, PipeTransform } from '@angular/core';
import { Timestamp } from '@angular/fire/firestore';

@Pipe({
  standalone: true,
  name: 'dateformator'
})
export class DateformatorPipe implements PipeTransform {

  transform(value: unknown, ...args: unknown[]): unknown {
    if (!value) return value;

    let date: Date;

    if (value instanceof Timestamp) {
      date = value.toDate();
    } else if (typeof value === 'string') {
      // Parse the date string from Firebase
      const dateString = value as string;
      const dateParts = dateString.split(' à ')[0].split(' ');
      const timeParts = dateString.split(' à ')[1].split(' ')[0].split(':');

      const day = parseInt(dateParts[0]);
      const month = this.getMonthNumber(dateParts[1]);
      const year = parseInt(dateParts[2]);
      const hours = parseInt(timeParts[0]);
      const minutes = parseInt(timeParts[1]);
      const seconds = parseInt(timeParts[2]);

      date = new Date(Date.UTC(year, month, day, hours, minutes, seconds));
    } else {
      return value;
    }

    const options: Intl.DateTimeFormatOptions = { weekday: 'short', day: '2-digit', month: 'short', year: '2-digit' };
    return date.toLocaleDateString('en-US', options);
  }

  private getMonthNumber(month: string): number {
    const months = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return months.indexOf(month);
  }
}
