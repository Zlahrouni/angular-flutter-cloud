import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'smartTruncate',
  standalone: true
})
export class SmartTruncatePipe implements PipeTransform {
  transform(value: string, maxLength: number = 100): string {
    if (!value) return '';
    if (value.length <= maxLength) return value;
    
    return value.slice(0, maxLength).trim() + '...';
  }
}